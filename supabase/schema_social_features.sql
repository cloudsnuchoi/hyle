-- =====================================================
-- HYLE Social Features Schema Extension
-- =====================================================
-- 소셜 기능, 길드, 플래시카드 등 추가 테이블

-- =====================================================
-- SOCIAL FEATURES (소셜 기능)
-- =====================================================

-- Friends/Following System (친구/팔로우)
CREATE TABLE IF NOT EXISTS user_relationships (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  follower_id UUID REFERENCES users(id) ON DELETE CASCADE,
  following_id UUID REFERENCES users(id) ON DELETE CASCADE,
  relationship_type TEXT CHECK (relationship_type IN ('friend', 'following', 'blocked')) DEFAULT 'following',
  is_mutual BOOLEAN DEFAULT FALSE, -- 서로 팔로우하면 친구
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(follower_id, following_id)
);

-- Friend Requests (친구 요청)
CREATE TABLE IF NOT EXISTS friend_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
  receiver_id UUID REFERENCES users(id) ON DELETE CASCADE,
  status TEXT CHECK (status IN ('pending', 'accepted', 'rejected', 'cancelled')) DEFAULT 'pending',
  message TEXT,
  responded_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(sender_id, receiver_id)
);

-- =====================================================
-- GUILD/GROUP SYSTEM (길드/그룹)
-- =====================================================

-- Guilds/Study Groups (길드/스터디 그룹)
CREATE TABLE IF NOT EXISTS guilds (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(100) UNIQUE NOT NULL,
  description TEXT,
  avatar_url TEXT,
  banner_url TEXT,
  
  -- Guild settings
  category TEXT CHECK (category IN ('study', 'language', 'coding', 'math', 'science', 'arts', 'general')),
  max_members INTEGER DEFAULT 50,
  is_public BOOLEAN DEFAULT TRUE,
  join_approval_required BOOLEAN DEFAULT FALSE,
  
  -- Stats
  member_count INTEGER DEFAULT 0,
  total_xp INTEGER DEFAULT 0,
  level INTEGER DEFAULT 1,
  weekly_active_members INTEGER DEFAULT 0,
  
  -- Metadata
  settings JSONB DEFAULT '{}',
  rules TEXT[],
  tags TEXT[],
  
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Guild Members (길드 멤버)
CREATE TABLE IF NOT EXISTS guild_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  guild_id UUID REFERENCES guilds(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  role TEXT CHECK (role IN ('owner', 'admin', 'moderator', 'member')) DEFAULT 'member',
  
  -- Member stats
  contribution_xp INTEGER DEFAULT 0,
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  last_active_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(guild_id, user_id)
);

-- Guild Missions (길드 미션)
CREATE TABLE IF NOT EXISTS guild_missions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  guild_id UUID REFERENCES guilds(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  
  -- Mission requirements
  type TEXT CHECK (type IN ('daily', 'weekly', 'special', 'raid')),
  requirements JSONB DEFAULT '{}',
  min_participants INTEGER DEFAULT 1,
  
  -- Rewards
  xp_reward INTEGER DEFAULT 0,
  guild_xp_reward INTEGER DEFAULT 0,
  badge_reward VARCHAR(100),
  
  -- Progress
  current_progress INTEGER DEFAULT 0,
  target_progress INTEGER DEFAULT 100,
  participants_count INTEGER DEFAULT 0,
  
  -- Timing
  starts_at TIMESTAMPTZ,
  ends_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- FLASHCARD SYSTEM (플래시카드)
-- =====================================================

-- Flashcard Decks (플래시카드 덱)
CREATE TABLE IF NOT EXISTS flashcard_decks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  creator_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  category VARCHAR(100),
  
  -- Deck settings
  is_public BOOLEAN DEFAULT TRUE,
  is_featured BOOLEAN DEFAULT FALSE,
  difficulty_level INTEGER CHECK (difficulty_level BETWEEN 1 AND 5),
  
  -- Stats
  card_count INTEGER DEFAULT 0,
  study_count INTEGER DEFAULT 0,
  average_score FLOAT DEFAULT 0,
  rating FLOAT DEFAULT 0,
  
  -- Metadata
  tags TEXT[],
  language VARCHAR(10) DEFAULT 'ko',
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Flashcards (개별 플래시카드)
CREATE TABLE IF NOT EXISTS flashcards (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  deck_id UUID REFERENCES flashcard_decks(id) ON DELETE CASCADE,
  
  -- Card content
  front_text TEXT NOT NULL,
  front_image_url TEXT,
  back_text TEXT NOT NULL,
  back_image_url TEXT,
  
  -- Additional info
  hint TEXT,
  explanation TEXT,
  
  -- Order
  position INTEGER NOT NULL,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Flashcard Progress (사용자 플래시카드 진행도)
CREATE TABLE IF NOT EXISTS user_flashcard_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  card_id UUID REFERENCES flashcards(id) ON DELETE CASCADE,
  deck_id UUID REFERENCES flashcard_decks(id) ON DELETE CASCADE,
  
  -- Spaced repetition data
  ease_factor FLOAT DEFAULT 2.5,
  interval_days INTEGER DEFAULT 1,
  repetitions INTEGER DEFAULT 0,
  
  -- Performance
  last_reviewed_at TIMESTAMPTZ,
  next_review_at TIMESTAMPTZ,
  correct_count INTEGER DEFAULT 0,
  incorrect_count INTEGER DEFAULT 0,
  
  UNIQUE(user_id, card_id)
);

-- =====================================================
-- STUDY REELS (스터디 릴스 - 30초 교육 콘텐츠)
-- =====================================================

CREATE TABLE IF NOT EXISTS study_reels (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  creator_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  -- Content
  title VARCHAR(255) NOT NULL,
  description TEXT,
  video_url TEXT NOT NULL,
  thumbnail_url TEXT,
  duration INTEGER DEFAULT 30, -- seconds
  
  -- Category
  subject VARCHAR(100),
  topic VARCHAR(100),
  difficulty_level INTEGER CHECK (difficulty_level BETWEEN 1 AND 5),
  
  -- Stats
  view_count INTEGER DEFAULT 0,
  like_count INTEGER DEFAULT 0,
  share_count INTEGER DEFAULT 0,
  save_count INTEGER DEFAULT 0,
  completion_rate FLOAT DEFAULT 0,
  
  -- AI analysis
  transcript TEXT,
  key_points TEXT[],
  ai_tags TEXT[],
  embedding vector(1536), -- For recommendation
  
  -- Status
  is_active BOOLEAN DEFAULT TRUE,
  is_featured BOOLEAN DEFAULT FALSE,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Reel Interactions (사용자 릴스 상호작용)
CREATE TABLE IF NOT EXISTS user_reel_interactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  reel_id UUID REFERENCES study_reels(id) ON DELETE CASCADE,
  
  -- Interaction types
  liked BOOLEAN DEFAULT FALSE,
  saved BOOLEAN DEFAULT FALSE,
  shared BOOLEAN DEFAULT FALSE,
  
  -- Watch data
  watch_time INTEGER DEFAULT 0, -- seconds
  watch_count INTEGER DEFAULT 0,
  completed BOOLEAN DEFAULT FALSE,
  
  -- Learning
  quiz_score FLOAT, -- If reel has quiz
  notes TEXT,
  
  last_watched_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(user_id, reel_id)
);

-- =====================================================
-- MESSAGING/CHAT SYSTEM (메시징/채팅)
-- =====================================================

-- Chat Rooms (채팅방)
CREATE TABLE IF NOT EXISTS chat_rooms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255),
  type TEXT CHECK (type IN ('direct', 'group', 'guild', 'study')) NOT NULL,
  
  -- For group chats
  max_members INTEGER DEFAULT 50,
  member_count INTEGER DEFAULT 0,
  
  -- For guild/study chats
  guild_id UUID REFERENCES guilds(id) ON DELETE CASCADE,
  
  -- Settings
  is_active BOOLEAN DEFAULT TRUE,
  settings JSONB DEFAULT '{}',
  
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Chat Members (채팅방 멤버)
CREATE TABLE IF NOT EXISTS chat_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  room_id UUID REFERENCES chat_rooms(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  -- Member settings
  role TEXT CHECK (role IN ('owner', 'admin', 'member')) DEFAULT 'member',
  nickname VARCHAR(100),
  
  -- Status
  is_muted BOOLEAN DEFAULT FALSE,
  last_read_at TIMESTAMPTZ,
  unread_count INTEGER DEFAULT 0,
  
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  left_at TIMESTAMPTZ,
  
  UNIQUE(room_id, user_id)
);

-- Messages (메시지)
CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  room_id UUID REFERENCES chat_rooms(id) ON DELETE CASCADE,
  sender_id UUID REFERENCES users(id) ON DELETE SET NULL,
  
  -- Message content
  content TEXT,
  type TEXT CHECK (type IN ('text', 'image', 'file', 'system', 'quiz', 'flashcard')) DEFAULT 'text',
  attachments JSONB DEFAULT '[]',
  
  -- Reply
  reply_to_id UUID REFERENCES messages(id) ON DELETE SET NULL,
  
  -- Status
  is_edited BOOLEAN DEFAULT FALSE,
  is_deleted BOOLEAN DEFAULT FALSE,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  edited_at TIMESTAMPTZ
);

-- =====================================================
-- LEADERBOARD/RANKING (리더보드/랭킹)
-- =====================================================

CREATE TABLE IF NOT EXISTS leaderboards (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  -- Different ranking categories
  total_xp INTEGER DEFAULT 0,
  weekly_xp INTEGER DEFAULT 0,
  monthly_xp INTEGER DEFAULT 0,
  
  -- Subject-specific
  math_xp INTEGER DEFAULT 0,
  science_xp INTEGER DEFAULT 0,
  language_xp INTEGER DEFAULT 0,
  coding_xp INTEGER DEFAULT 0,
  
  -- Rankings (updated by cron job)
  global_rank INTEGER,
  weekly_rank INTEGER,
  monthly_rank INTEGER,
  guild_rank INTEGER,
  
  -- Stats
  study_time_total INTEGER DEFAULT 0, -- minutes
  study_time_week INTEGER DEFAULT 0,
  study_time_month INTEGER DEFAULT 0,
  
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(user_id)
);

-- =====================================================
-- NOTIFICATION SYSTEM (알림)
-- =====================================================

CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  -- Notification details
  type VARCHAR(50) NOT NULL, -- 'friend_request', 'guild_invite', 'quest_complete', etc.
  title VARCHAR(255) NOT NULL,
  message TEXT,
  
  -- Related entities
  related_id UUID, -- ID of related entity (user, guild, quest, etc.)
  related_type VARCHAR(50), -- Type of related entity
  
  -- Action
  action_url TEXT,
  action_data JSONB,
  
  -- Status
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMPTZ,
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- ACHIEVEMENT/BADGE SYSTEM (업적/배지)
-- =====================================================

CREATE TABLE IF NOT EXISTS achievements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(100) UNIQUE NOT NULL,
  description TEXT,
  
  -- Badge info
  icon_url TEXT,
  badge_color VARCHAR(7), -- Hex color
  
  -- Requirements
  category VARCHAR(50),
  requirements JSONB NOT NULL,
  
  -- Rewards
  xp_reward INTEGER DEFAULT 0,
  title_reward VARCHAR(100),
  
  -- Rarity
  rarity TEXT CHECK (rarity IN ('common', 'rare', 'epic', 'legendary')) DEFAULT 'common',
  
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Achievements (사용자 업적)
CREATE TABLE IF NOT EXISTS user_achievements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  achievement_id UUID REFERENCES achievements(id) ON DELETE CASCADE,
  
  progress INTEGER DEFAULT 0,
  target INTEGER DEFAULT 100,
  completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMPTZ,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(user_id, achievement_id)
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Social indexes
CREATE INDEX idx_user_relationships_follower ON user_relationships(follower_id);
CREATE INDEX idx_user_relationships_following ON user_relationships(following_id);
CREATE INDEX idx_friend_requests_receiver ON friend_requests(receiver_id);

-- Guild indexes
CREATE INDEX idx_guild_members_user ON guild_members(user_id);
CREATE INDEX idx_guild_members_guild ON guild_members(guild_id);

-- Flashcard indexes
CREATE INDEX idx_flashcards_deck ON flashcards(deck_id);
CREATE INDEX idx_user_flashcard_progress_user ON user_flashcard_progress(user_id);
CREATE INDEX idx_user_flashcard_progress_next_review ON user_flashcard_progress(next_review_at);

-- Reels indexes
CREATE INDEX idx_study_reels_creator ON study_reels(creator_id);
CREATE INDEX idx_user_reel_interactions_user ON user_reel_interactions(user_id);

-- Chat indexes
CREATE INDEX idx_chat_members_user ON chat_members(user_id);
CREATE INDEX idx_messages_room ON messages(room_id);
CREATE INDEX idx_messages_created ON messages(created_at DESC);

-- Notification indexes
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_unread ON notifications(user_id, is_read) WHERE is_read = FALSE;

-- Leaderboard indexes
CREATE INDEX idx_leaderboards_global_rank ON leaderboards(global_rank);
CREATE INDEX idx_leaderboards_weekly_xp ON leaderboards(weekly_xp DESC);

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS on all new tables
ALTER TABLE user_relationships ENABLE ROW LEVEL SECURITY;
ALTER TABLE friend_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE guilds ENABLE ROW LEVEL SECURITY;
ALTER TABLE guild_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE guild_missions ENABLE ROW LEVEL SECURITY;
ALTER TABLE flashcard_decks ENABLE ROW LEVEL SECURITY;
ALTER TABLE flashcards ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_flashcard_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_reels ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_reel_interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE leaderboards ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;

-- Basic RLS Policies (users can only access their own data or public data)
-- Note: These are simplified. You'll need to adjust based on your specific requirements.

-- User relationships: Users can see their own relationships
CREATE POLICY "Users can view own relationships" ON user_relationships 
  FOR SELECT USING (auth.uid() = follower_id OR auth.uid() = following_id);

CREATE POLICY "Users can create relationships" ON user_relationships 
  FOR INSERT WITH CHECK (auth.uid() = follower_id);

-- Guilds: Public guilds visible to all, private guilds to members only
CREATE POLICY "Public guilds visible to all" ON guilds 
  FOR SELECT USING (is_public = TRUE OR EXISTS (
    SELECT 1 FROM guild_members WHERE guild_id = guilds.id AND user_id = auth.uid()
  ));

-- Messages: Only room members can see messages
CREATE POLICY "Room members can view messages" ON messages 
  FOR SELECT USING (EXISTS (
    SELECT 1 FROM chat_members WHERE room_id = messages.room_id AND user_id = auth.uid()
  ));

-- Notifications: Users can only see their own notifications
CREATE POLICY "Users can view own notifications" ON notifications 
  FOR SELECT USING (auth.uid() = user_id);

-- Add more policies as needed...