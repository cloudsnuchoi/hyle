-- =====================================================
-- Apply Consolidation Migration Script
-- 이 스크립트를 Supabase SQL Editor에서 실행하세요
-- =====================================================

-- 먼저 현재 테이블 상태 확인
DO $$
BEGIN
  RAISE NOTICE '======================================';
  RAISE NOTICE 'Pre-Migration Status Check';
  RAISE NOTICE '======================================';
  
  -- Check if duplicate essay tables exist
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'essay_topics') THEN
    RAISE NOTICE '✓ essay_topics table exists (from 006/007)';
  END IF;
  
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'questions') THEN
    RAISE NOTICE '✓ questions table exists (from 010)';
  END IF;
  
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'users') THEN
    RAISE NOTICE '✓ users table exists (duplicate)';
  END IF;
  
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'users_profile') THEN
    RAISE NOTICE '✓ users_profile table exists';
  END IF;
END $$;

-- 실제 마이그레이션 실행
-- 011_consolidation_and_cleanup.sql 내용을 여기에 포함시킬 수도 있지만
-- 별도 파일로 실행하는 것을 권장

-- 마이그레이션 후 상태 확인
DO $$
DECLARE
  table_count INTEGER;
  policy_count INTEGER;
  index_count INTEGER;
BEGIN
  RAISE NOTICE '======================================';
  RAISE NOTICE 'Post-Migration Verification';
  RAISE NOTICE '======================================';
  
  -- Count tables
  SELECT COUNT(*) INTO table_count 
  FROM information_schema.tables 
  WHERE table_schema = 'public';
  RAISE NOTICE 'Total tables: %', table_count;
  
  -- Count RLS policies
  SELECT COUNT(*) INTO policy_count 
  FROM pg_policies 
  WHERE schemaname = 'public';
  RAISE NOTICE 'Total RLS policies: %', policy_count;
  
  -- Count indexes
  SELECT COUNT(*) INTO index_count 
  FROM pg_indexes 
  WHERE schemaname = 'public';
  RAISE NOTICE 'Total indexes: %', index_count;
  
  -- Check if consolidation was successful
  IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'essay_topics') AND
     EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'questions') THEN
    RAISE NOTICE '✅ Essay tables consolidated successfully';
  ELSE
    RAISE WARNING '⚠️ Essay table consolidation may have issues';
  END IF;
  
  IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'users') AND
     EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'users_profile') THEN
    RAISE NOTICE '✅ User tables consolidated successfully';
  ELSE
    RAISE WARNING '⚠️ User table consolidation may have issues';
  END IF;
  
  -- Check helper functions
  IF EXISTS (SELECT FROM pg_proc WHERE proname = 'is_premium_user') THEN
    RAISE NOTICE '✅ Helper function is_premium_user exists';
  END IF;
  
  IF EXISTS (SELECT FROM pg_proc WHERE proname = 'is_admin_user') THEN
    RAISE NOTICE '✅ Helper function is_admin_user exists';
  END IF;
  
  IF EXISTS (SELECT FROM pg_proc WHERE proname = 'get_admin_role') THEN
    RAISE NOTICE '✅ Helper function get_admin_role exists';
  END IF;
  
  RAISE NOTICE '======================================';
  RAISE NOTICE 'Migration Verification Complete!';
  RAISE NOTICE '======================================';
END $$;