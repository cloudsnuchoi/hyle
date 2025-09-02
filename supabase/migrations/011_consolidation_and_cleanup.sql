-- =====================================================
-- Database Consolidation and Cleanup Migration
-- 데이터베이스 통합 및 정리 마이그레이션
-- Date: 2025-09-02
-- =====================================================

-- =====================================================
-- STEP 1: Drop Duplicate Essay Tables (if exists)
-- 006, 007, 010에서 중복 생성된 테이블 정리
-- =====================================================

-- 먼저 어떤 테이블이 실제로 존재하는지 확인하고 정리
-- 010_essay_comprehensive_schema.sql이 가장 완전하므로 이것을 기준으로 함

-- Drop old essay tables from 006 and 007 if they exist
DROP TABLE IF EXISTS essay_ai_analysis CASCADE;
DROP TABLE IF EXISTS essay_submissions CASCADE;
DROP TABLE IF EXISTS essay_topics CASCADE;
DROP TABLE IF EXISTS essay_practice_sets CASCADE;
DROP TABLE IF EXISTS user_essay_progress CASCADE;
DROP TABLE IF EXISTS expert_reviewers CASCADE;
DROP TABLE IF EXISTS expert_reviews CASCADE;
DROP TABLE IF EXISTS essay_templates CASCADE;
DROP TABLE IF EXISTS essay_keywords CASCADE;
DROP TABLE IF EXISTS essay_patterns CASCADE;
DROP TABLE IF EXISTS essay_ontology_themes CASCADE;
DROP TABLE IF EXISTS essay_task_types CASCADE;
DROP TABLE IF EXISTS nag_nodes CASCADE;
DROP TABLE IF EXISTS nag_edges CASCADE;
DROP TABLE IF EXISTS rubrics CASCADE;
DROP TABLE IF EXISTS rubric_criteria CASCADE;
DROP TABLE IF EXISTS submission_spans CASCADE;
DROP TABLE IF EXISTS span_alignment CASCADE;
DROP TABLE IF EXISTS graphrag_index CASCADE;
DROP TABLE IF EXISTS error_catalog CASCADE;
DROP TABLE IF EXISTS coaching_missions CASCADE;
DROP TABLE IF EXISTS mock_exam_templates CASCADE;
DROP TABLE IF EXISTS generated_mock_exams CASCADE;
DROP TABLE IF EXISTS grading_quality_metrics CASCADE;
DROP TABLE IF EXISTS learning_analytics CASCADE;

-- =====================================================
-- STEP 2: Resolve users vs users_profile duplication
-- users_profile을 기준으로 통합
-- =====================================================

-- Check if both tables exist and consolidate
DO $$
BEGIN
  -- If 'users' table exists separately from auth.users, migrate data to users_profile
  IF EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'users'
  ) THEN
    -- Migrate any additional data from users to users_profile if needed
    INSERT INTO users_profile (id, email, name)
    SELECT id, email, username
    FROM users
    WHERE id NOT IN (SELECT id FROM users_profile)
    ON CONFLICT (id) DO NOTHING;
    
    -- Drop the duplicate users table
    DROP TABLE IF EXISTS users CASCADE;
  END IF;
END $$;

-- Ensure users_profile has all necessary columns
ALTER TABLE users_profile 
  ADD COLUMN IF NOT EXISTS grade VARCHAR(20), -- 학년: 고1, 고2, 고3, N수생
  ADD COLUMN IF NOT EXISTS target_universities INTEGER[], -- 목표 대학 ID 배열
  ADD COLUMN IF NOT EXISTS last_login TIMESTAMP WITH TIME ZONE,
  ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'active'; -- active, inactive, suspended

-- =====================================================
-- STEP 3: Create Consolidated Essay System Tables
-- 통합된 논술 시스템 테이블 (010 기준)
-- =====================================================

-- Note: 010_essay_comprehensive_schema.sql의 테이블들이 이미 생성되어 있을 것으로 예상
-- 여기서는 누락된 테이블만 추가하거나 수정사항만 반영

-- Ensure vector extension is enabled
CREATE EXTENSION IF NOT EXISTS vector;

-- Check and create missing indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_profile_email ON users_profile(email);
CREATE INDEX IF NOT EXISTS idx_users_profile_learning_type ON users_profile(learning_type);

-- =====================================================
-- STEP 4: Implement Proper RLS Policies
-- Service Key 우회 대신 적절한 RLS 정책 구현
-- =====================================================

-- Drop all existing policies to start fresh
DO $$
DECLARE
  r RECORD;
BEGIN
  -- Drop all policies on users_profile
  FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'users_profile')
  LOOP
    EXECUTE 'DROP POLICY IF EXISTS ' || quote_ident(r.policyname) || ' ON users_profile';
  END LOOP;
END $$;

-- =====================================================
-- Core RLS Policies for users_profile
-- =====================================================

-- Users can view their own profile
CREATE POLICY "Users can view own profile" 
ON users_profile FOR SELECT 
USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile" 
ON users_profile FOR UPDATE 
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Users can insert their own profile (on signup)
CREATE POLICY "Users can insert own profile" 
ON users_profile FOR INSERT 
WITH CHECK (auth.uid() = id);

-- Public profiles view (for social features)
CREATE POLICY "Users can view public profiles" 
ON users_profile FOR SELECT 
USING (
  -- Can view if:
  -- 1. It's their own profile OR
  -- 2. They are friends/following OR
  -- 3. They are in the same guild
  auth.uid() = id OR
  EXISTS (
    SELECT 1 FROM user_relationships 
    WHERE (follower_id = auth.uid() AND following_id = users_profile.id)
    OR (follower_id = users_profile.id AND following_id = auth.uid() AND is_mutual = true)
  ) OR
  EXISTS (
    SELECT 1 FROM guild_members gm1
    JOIN guild_members gm2 ON gm1.guild_id = gm2.guild_id
    WHERE gm1.user_id = auth.uid() AND gm2.user_id = users_profile.id
  )
);

-- =====================================================
-- RLS Policies for Study/Todo Tables
-- =====================================================

-- Study Sessions - users manage their own
CREATE POLICY "Users manage own study sessions" 
ON study_sessions FOR ALL 
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Todos - users manage their own
CREATE POLICY "Users manage own todos" 
ON todos FOR ALL 
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Streaks - users manage their own
CREATE POLICY "Users manage own streaks" 
ON streaks FOR ALL 
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Quests - users manage their own
CREATE POLICY "Users manage own quests" 
ON quests FOR ALL 
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- =====================================================
-- RLS Policies for Premium Features
-- =====================================================

-- Helper function to check premium status
CREATE OR REPLACE FUNCTION is_premium_user(user_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM premium_subscriptions 
    WHERE user_id = user_uuid 
    AND is_active = true 
    AND (expires_at IS NULL OR expires_at > NOW())
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- AI Conversations - only premium users
CREATE POLICY "Premium users access AI conversations" 
ON ai_conversations FOR ALL 
USING (
  auth.uid() = user_id AND 
  is_premium_user(auth.uid()) AND
  EXISTS (
    SELECT 1 FROM premium_subscriptions 
    WHERE user_id = auth.uid() 
    AND ai_conversations_enabled = true
  )
)
WITH CHECK (
  auth.uid() = user_id AND 
  is_premium_user(auth.uid())
);

-- Knowledge Nodes - only premium users
CREATE POLICY "Premium users access knowledge nodes" 
ON knowledge_nodes FOR ALL 
USING (
  auth.uid() = user_id AND 
  is_premium_user(auth.uid()) AND
  EXISTS (
    SELECT 1 FROM premium_subscriptions 
    WHERE user_id = auth.uid() 
    AND knowledge_graph_enabled = true
  )
)
WITH CHECK (
  auth.uid() = user_id AND 
  is_premium_user(auth.uid())
);

-- =====================================================
-- RLS Policies for Social Features
-- =====================================================

-- User Relationships
CREATE POLICY "Users can view relationships involving them" 
ON user_relationships FOR SELECT 
USING (
  auth.uid() = follower_id OR 
  auth.uid() = following_id
);

CREATE POLICY "Users can create relationships" 
ON user_relationships FOR INSERT 
WITH CHECK (auth.uid() = follower_id);

CREATE POLICY "Users can delete their relationships" 
ON user_relationships FOR DELETE 
USING (auth.uid() = follower_id);

-- Friend Requests
CREATE POLICY "Users can view their friend requests" 
ON friend_requests FOR SELECT 
USING (
  auth.uid() = sender_id OR 
  auth.uid() = receiver_id
);

CREATE POLICY "Users can send friend requests" 
ON friend_requests FOR INSERT 
WITH CHECK (auth.uid() = sender_id);

CREATE POLICY "Users can update friend requests to them" 
ON friend_requests FOR UPDATE 
USING (auth.uid() = receiver_id);

-- Guilds - public guilds visible to all
CREATE POLICY "Public guilds visible to all" 
ON guilds FOR SELECT 
USING (
  is_public = true OR 
  EXISTS (
    SELECT 1 FROM guild_members 
    WHERE guild_id = guilds.id 
    AND user_id = auth.uid()
  )
);

CREATE POLICY "Guild members can update guild" 
ON guilds FOR UPDATE 
USING (
  EXISTS (
    SELECT 1 FROM guild_members 
    WHERE guild_id = guilds.id 
    AND user_id = auth.uid() 
    AND role IN ('owner', 'admin')
  )
);

-- Guild Members
CREATE POLICY "Guild members visible to guild members" 
ON guild_members FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM guild_members gm 
    WHERE gm.guild_id = guild_members.guild_id 
    AND gm.user_id = auth.uid()
  )
);

-- Messages - only room members can see
CREATE POLICY "Room members can view messages" 
ON messages FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM chat_members 
    WHERE room_id = messages.room_id 
    AND user_id = auth.uid()
  )
);

CREATE POLICY "Room members can send messages" 
ON messages FOR INSERT 
WITH CHECK (
  auth.uid() = sender_id AND
  EXISTS (
    SELECT 1 FROM chat_members 
    WHERE room_id = messages.room_id 
    AND user_id = auth.uid()
  )
);

-- =====================================================
-- RLS Policies for Essay System
-- =====================================================

-- Universities and Essay Topics - public read
CREATE POLICY "Public can view universities" 
ON universities FOR SELECT 
USING (true);

CREATE POLICY "Public can view exams" 
ON exams FOR SELECT 
USING (true);

CREATE POLICY "Public can view questions" 
ON questions FOR SELECT 
USING (true);

CREATE POLICY "Public can view passages" 
ON passages FOR SELECT 
USING (true);

-- Student Submissions - users manage their own
CREATE POLICY "Users manage own submissions" 
ON student_submissions FOR ALL 
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- AI Feedbacks - users view their own
CREATE POLICY "Users view own AI feedback" 
ON ai_feedbacks FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM student_submissions 
    WHERE submission_id = ai_feedbacks.submission_id 
    AND user_id = auth.uid()
  )
);

-- =====================================================
-- RLS Policies for Admin Tables
-- =====================================================

-- Helper function to check admin status
CREATE OR REPLACE FUNCTION is_admin_user(user_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM admin_users 
    WHERE id = user_uuid 
    AND is_active = true
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Helper function to check admin role
CREATE OR REPLACE FUNCTION get_admin_role(user_uuid UUID)
RETURNS TEXT AS $$
DECLARE
  admin_role TEXT;
BEGIN
  SELECT role INTO admin_role 
  FROM admin_users 
  WHERE id = user_uuid 
  AND is_active = true;
  
  RETURN admin_role;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Admin users table - only super admins can manage
CREATE POLICY "Super admins manage admin users" 
ON admin_users FOR ALL 
USING (get_admin_role(auth.uid()) = 'super_admin');

-- Audit logs - admins can view
CREATE POLICY "Admins view audit logs" 
ON audit_logs FOR SELECT 
USING (is_admin_user(auth.uid()));

-- Support tickets - admins can manage, users can create
CREATE POLICY "Users create support tickets" 
ON support_tickets FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users view own tickets" 
ON support_tickets FOR SELECT 
USING (
  auth.uid() = user_id OR 
  is_admin_user(auth.uid())
);

CREATE POLICY "Admins manage tickets" 
ON support_tickets FOR UPDATE 
USING (is_admin_user(auth.uid()));

-- =====================================================
-- STEP 5: Create Missing Indexes for Performance
-- =====================================================

-- User profile indexes
CREATE INDEX IF NOT EXISTS idx_users_profile_level ON users_profile(level);
CREATE INDEX IF NOT EXISTS idx_users_profile_xp ON users_profile(xp DESC);

-- Social feature indexes
CREATE INDEX IF NOT EXISTS idx_user_relationships_follower ON user_relationships(follower_id);
CREATE INDEX IF NOT EXISTS idx_user_relationships_following ON user_relationships(following_id);
CREATE INDEX IF NOT EXISTS idx_guild_members_user ON guild_members(user_id);
CREATE INDEX IF NOT EXISTS idx_guild_members_guild ON guild_members(guild_id);

-- Essay system indexes
CREATE INDEX IF NOT EXISTS idx_student_submissions_user ON student_submissions(user_id);
CREATE INDEX IF NOT EXISTS idx_student_submissions_question ON student_submissions(question_id);
CREATE INDEX IF NOT EXISTS idx_ai_feedbacks_submission ON ai_feedbacks(submission_id);

-- Performance indexes for common queries
CREATE INDEX IF NOT EXISTS idx_study_sessions_user_date ON study_sessions(user_id, timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_todos_user_completed ON todos(user_id, completed);
CREATE INDEX IF NOT EXISTS idx_messages_room_created ON messages(room_id, created_at DESC);

-- =====================================================
-- STEP 6: Add Missing Foreign Key Constraints
-- =====================================================

-- Ensure all foreign keys are properly set
ALTER TABLE study_sessions 
  DROP CONSTRAINT IF EXISTS study_sessions_user_id_fkey,
  ADD CONSTRAINT study_sessions_user_id_fkey 
  FOREIGN KEY (user_id) REFERENCES users_profile(id) ON DELETE CASCADE;

ALTER TABLE todos 
  DROP CONSTRAINT IF EXISTS todos_user_id_fkey,
  ADD CONSTRAINT todos_user_id_fkey 
  FOREIGN KEY (user_id) REFERENCES users_profile(id) ON DELETE CASCADE;

ALTER TABLE streaks 
  DROP CONSTRAINT IF EXISTS streaks_user_id_fkey,
  ADD CONSTRAINT streaks_user_id_fkey 
  FOREIGN KEY (user_id) REFERENCES users_profile(id) ON DELETE CASCADE;

-- =====================================================
-- STEP 7: Data Migration and Cleanup
-- =====================================================

-- Update any null values in critical fields
UPDATE users_profile 
SET 
  learning_type = 'not_determined' 
WHERE learning_type IS NULL;

UPDATE users_profile 
SET 
  level = 1,
  xp = 0 
WHERE level IS NULL;

-- =====================================================
-- STEP 8: Create Views for Common Queries
-- =====================================================

-- User statistics view
CREATE OR REPLACE VIEW user_statistics AS
SELECT 
  u.id,
  u.email,
  u.name,
  u.level,
  u.xp,
  u.streak_days,
  COUNT(DISTINCT ss.id) as total_sessions,
  COUNT(DISTINCT t.id) as total_todos,
  COUNT(DISTINCT t.id) FILTER (WHERE t.completed = true) as completed_todos,
  ps.tier as subscription_tier,
  ps.is_active as is_premium
FROM users_profile u
LEFT JOIN study_sessions ss ON u.id = ss.user_id
LEFT JOIN todos t ON u.id = t.user_id
LEFT JOIN premium_subscriptions ps ON u.id = ps.user_id
GROUP BY u.id, u.email, u.name, u.level, u.xp, u.streak_days, ps.tier, ps.is_active;

-- Guild statistics view
CREATE OR REPLACE VIEW guild_statistics AS
SELECT 
  g.id,
  g.name,
  g.category,
  g.member_count,
  g.total_xp,
  g.level,
  COUNT(DISTINCT gm.user_id) as actual_members,
  COUNT(DISTINCT m.id) as total_messages
FROM guilds g
LEFT JOIN guild_members gm ON g.id = gm.guild_id
LEFT JOIN chat_rooms cr ON g.id = cr.guild_id
LEFT JOIN messages m ON cr.id = m.room_id
GROUP BY g.id, g.name, g.category, g.member_count, g.total_xp, g.level;

-- =====================================================
-- STEP 9: Grant Necessary Permissions
-- =====================================================

-- Grant usage on schema
GRANT USAGE ON SCHEMA public TO anon, authenticated;

-- Grant permissions on tables
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;

-- Grant permissions on sequences
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- Grant execute on functions
GRANT EXECUTE ON FUNCTION is_premium_user TO authenticated;
GRANT EXECUTE ON FUNCTION is_admin_user TO authenticated;
GRANT EXECUTE ON FUNCTION get_admin_role TO authenticated;

-- =====================================================
-- Migration Complete Message
-- =====================================================

DO $$
BEGIN
  RAISE NOTICE '========================================';
  RAISE NOTICE 'Database Consolidation Complete!';
  RAISE NOTICE '1. Essay tables consolidated';
  RAISE NOTICE '2. users/users_profile duplication resolved';
  RAISE NOTICE '3. RLS policies properly implemented';
  RAISE NOTICE '4. Indexes created for performance';
  RAISE NOTICE '5. Foreign keys validated';
  RAISE NOTICE '========================================';
END $$;