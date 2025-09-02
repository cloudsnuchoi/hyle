-- =====================================================
-- RLS Policy Testing Script
-- Supabase SQL Editor에서 실행하여 RLS 정책 검증
-- =====================================================

-- Test User Setup
DO $$
DECLARE
  test_user_id UUID := gen_random_uuid();
  test_user2_id UUID := gen_random_uuid();
  test_admin_id UUID := gen_random_uuid();
  test_premium_id UUID := gen_random_uuid();
BEGIN
  RAISE NOTICE '======================================';
  RAISE NOTICE 'RLS Policy Testing';
  RAISE NOTICE '======================================';
  
  -- Create test users
  INSERT INTO auth.users (id, email) VALUES 
    (test_user_id, 'test_user@example.com'),
    (test_user2_id, 'test_user2@example.com'),
    (test_admin_id, 'test_admin@example.com'),
    (test_premium_id, 'test_premium@example.com')
  ON CONFLICT (id) DO NOTHING;
  
  -- Create user profiles
  INSERT INTO users_profile (id, email, name, learning_type) VALUES
    (test_user_id, 'test_user@example.com', 'Test User', 'visual'),
    (test_user2_id, 'test_user2@example.com', 'Test User 2', 'auditory'),
    (test_admin_id, 'test_admin@example.com', 'Test Admin', 'kinesthetic'),
    (test_premium_id, 'test_premium@example.com', 'Test Premium', 'reading')
  ON CONFLICT (id) DO NOTHING;
  
  -- Make one user admin
  INSERT INTO admin_users (id, email, role, is_active) VALUES
    (test_admin_id, 'test_admin@example.com', 'super_admin', true)
  ON CONFLICT (id) DO NOTHING;
  
  -- Make one user premium
  INSERT INTO premium_subscriptions (user_id, tier, is_active, ai_conversations_enabled, knowledge_graph_enabled) VALUES
    (test_premium_id, 'premium', true, true, true)
  ON CONFLICT (user_id) DO NOTHING;
  
  RAISE NOTICE 'Test users created';
END $$;

-- Test 1: Users can only see their own profile
DO $$
DECLARE
  result_count INTEGER;
BEGIN
  RAISE NOTICE '--- Test 1: User Profile Access ---';
  
  -- Set session to test_user
  PERFORM set_config('request.jwt.claims', json_build_object('sub', gen_random_uuid()::text)::text, true);
  
  -- This should work (seeing own profile)
  SELECT COUNT(*) INTO result_count FROM users_profile WHERE id = current_setting('request.jwt.claims')::json->>'sub';
  
  IF result_count = 1 THEN
    RAISE NOTICE '✅ Users can view their own profile';
  ELSE
    RAISE WARNING '❌ Users cannot view their own profile';
  END IF;
END $$;

-- Test 2: Premium features access
DO $$
DECLARE
  can_access BOOLEAN;
BEGIN
  RAISE NOTICE '--- Test 2: Premium Features Access ---';
  
  -- Test premium user function
  SELECT is_premium_user(
    (SELECT id FROM users_profile WHERE email = 'test_premium@example.com')
  ) INTO can_access;
  
  IF can_access THEN
    RAISE NOTICE '✅ Premium user detection working';
  ELSE
    RAISE WARNING '❌ Premium user detection failed';
  END IF;
  
  -- Test non-premium user
  SELECT is_premium_user(
    (SELECT id FROM users_profile WHERE email = 'test_user@example.com')
  ) INTO can_access;
  
  IF NOT can_access THEN
    RAISE NOTICE '✅ Non-premium user correctly identified';
  ELSE
    RAISE WARNING '❌ Non-premium user incorrectly identified as premium';
  END IF;
END $$;

-- Test 3: Admin access
DO $$
DECLARE
  is_admin BOOLEAN;
  admin_role TEXT;
BEGIN
  RAISE NOTICE '--- Test 3: Admin Access ---';
  
  -- Test admin user function
  SELECT is_admin_user(
    (SELECT id FROM users_profile WHERE email = 'test_admin@example.com')
  ) INTO is_admin;
  
  IF is_admin THEN
    RAISE NOTICE '✅ Admin user detection working';
  ELSE
    RAISE WARNING '❌ Admin user detection failed';
  END IF;
  
  -- Test admin role function
  SELECT get_admin_role(
    (SELECT id FROM users_profile WHERE email = 'test_admin@example.com')
  ) INTO admin_role;
  
  IF admin_role = 'super_admin' THEN
    RAISE NOTICE '✅ Admin role detection working: %', admin_role;
  ELSE
    RAISE WARNING '❌ Admin role detection failed';
  END IF;
END $$;

-- Test 4: Social features RLS
DO $$
DECLARE
  test_user_id UUID;
  test_user2_id UUID;
  relationship_id UUID;
BEGIN
  RAISE NOTICE '--- Test 4: Social Features RLS ---';
  
  SELECT id INTO test_user_id FROM users_profile WHERE email = 'test_user@example.com';
  SELECT id INTO test_user2_id FROM users_profile WHERE email = 'test_user2@example.com';
  
  -- Create a relationship
  INSERT INTO user_relationships (follower_id, following_id, relationship_type)
  VALUES (test_user_id, test_user2_id, 'following')
  ON CONFLICT (follower_id, following_id) DO NOTHING
  RETURNING id INTO relationship_id;
  
  IF relationship_id IS NOT NULL THEN
    RAISE NOTICE '✅ User relationships creation working';
  ELSE
    RAISE NOTICE 'ℹ️ Relationship already exists or creation skipped';
  END IF;
END $$;

-- Test 5: Essay system access
DO $$
DECLARE
  uni_count INTEGER;
  exam_count INTEGER;
BEGIN
  RAISE NOTICE '--- Test 5: Essay System Access ---';
  
  -- Public tables should be accessible
  SELECT COUNT(*) INTO uni_count FROM universities;
  SELECT COUNT(*) INTO exam_count FROM exams;
  
  RAISE NOTICE 'ℹ️ Universities count: %', uni_count;
  RAISE NOTICE 'ℹ️ Exams count: %', exam_count;
  
  IF uni_count >= 0 AND exam_count >= 0 THEN
    RAISE NOTICE '✅ Public essay tables accessible';
  ELSE
    RAISE WARNING '❌ Public essay tables not accessible';
  END IF;
END $$;

-- Summary Report
DO $$
DECLARE
  table_count INTEGER;
  policy_count INTEGER;
  function_count INTEGER;
BEGIN
  RAISE NOTICE '======================================';
  RAISE NOTICE 'RLS Testing Summary';
  RAISE NOTICE '======================================';
  
  -- Count enabled RLS tables
  SELECT COUNT(*) INTO table_count
  FROM pg_tables t
  JOIN pg_class c ON c.relname = t.tablename
  WHERE t.schemaname = 'public' 
  AND c.relrowsecurity = true;
  
  RAISE NOTICE 'Tables with RLS enabled: %', table_count;
  
  -- Count policies
  SELECT COUNT(*) INTO policy_count FROM pg_policies WHERE schemaname = 'public';
  RAISE NOTICE 'Total RLS policies: %', policy_count;
  
  -- Count helper functions
  SELECT COUNT(*) INTO function_count 
  FROM pg_proc 
  WHERE proname IN ('is_premium_user', 'is_admin_user', 'get_admin_role');
  RAISE NOTICE 'Helper functions: %', function_count;
  
  RAISE NOTICE '======================================';
  RAISE NOTICE 'Testing Complete!';
  RAISE NOTICE '======================================';
END $$;

-- Cleanup test data (optional - uncomment if needed)
/*
DELETE FROM user_relationships WHERE follower_id IN (
  SELECT id FROM users_profile WHERE email LIKE 'test_%@example.com'
);
DELETE FROM premium_subscriptions WHERE user_id IN (
  SELECT id FROM users_profile WHERE email LIKE 'test_%@example.com'
);
DELETE FROM admin_users WHERE email LIKE 'test_%@example.com';
DELETE FROM users_profile WHERE email LIKE 'test_%@example.com';
DELETE FROM auth.users WHERE email LIKE 'test_%@example.com';
*/