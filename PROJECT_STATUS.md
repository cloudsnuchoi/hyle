# HYLE 프로젝트 현황 (2025-09-02 업데이트)

## 🚀 최신 진행 상황

### 인문논술 AI 채점 시스템 (🆕 2025-09-02)
- ✅ 온톨로지 + GraphRAG 기반 시스템 설계 완료
- ✅ NAG (Normative Answer Graph) 정답 그래프 구조 설계
- ✅ 7단계 채점 파이프라인 구축 (프리체크 → LLM 합의 채점)
- ✅ 10개 대학 데이터 구조 설계 (연세대, 고려대, 성균관대 등)
- ✅ 15개 핵심 테이블 + pgvector 임베딩 검색 구현
- ✅ 4가지 대학별 논술 유형 분류 (전문가 분석 반영)
- ⏳ Supabase 스키마 적용 대기
- ⏳ 기출문제 데이터 수집 필요

### HYLE Admin Dashboard (✅ 완전 작동!)
- ✅ Supabase 연동 완료
- ✅ 인증 시스템 구현 (Service Key 활용)
- ✅ 사용자 관리 실제 데이터 연동
- ✅ 모든 대시보드 페이지 UI 구현
- ✅ GitHub 저장소 생성 및 연동
- ✅ TypeScript 에러 모두 해결 (100개 이상)
- ✅ 로컬 빌드 성공
- ✅ Vercel 배포 성공 (hyle-admin-2c3w.vercel.app)
- ✅ 환경 변수 안전 처리 완료
- ✅ 환경 변수 설정 완료 (2025-08-31)
- ✅ 로그인 기능 정상 작동 확인

### Flutter 앱 (HYLE)
- ✅ Supabase 마이그레이션 완료
- ✅ 로컬 테스트 모드 작동 (main_test_local.dart)
- ⏳ Admin Dashboard 배포 후 연동 예정
- ⏳ 실제 Supabase 연결 대기 중
- ❗ 타입 에러 약 400개 수정 필요

## 📁 프로젝트 구조
```
C:\dev\git\
├── hyle\               # Flutter 모바일 앱
│   ├── lib\            # Flutter 소스 코드
│   ├── supabase\       # Supabase 스키마
│   │   └── migrations\ # DB 마이그레이션 (006~010 추가됨)
│   ├── ref\            # 인문논술 PRD 문서
│   └── CLAUDE.md       # Claude 가이드
│
└── hyle-admin\         # Next.js 관리자 대시보드
    ├── src\            # Next.js 소스 코드
    ├── supabase\       # DB 마이그레이션
    └── .env.local      # 환경 변수

GitHub Repositories:
- https://github.com/cloudsnuchoi/hyle-admin (main branch)
```

## 📊 데이터베이스 구조 (대규모 확장!)

### 핵심 테이블
- users (사용자 - RLS 문제로 Service Key 사용 중)
- courses (강좌)
- enrollments (수강 정보)
- assignments (과제)
- submissions (제출물)
- live_classes (실시간 수업)

### 학습 콘텐츠
- textbooks (교재)
- quizzes (퀴즈)
- quiz_questions (퀴즈 문제)
- flashcard_decks (플래시카드 덱)
- flashcards (개별 카드)

### 소셜 기능 (🆕 2025-08-31)
- user_relationships (친구/팔로우)
- guilds (길드/스터디 그룹)
- chat_rooms (채팅방)
- messages (메시지)
- leaderboards (리더보드)
- achievements (업적)

### 인문논술 AI (🆕 2025-09-02)
- universities (대학 정보 - 10개 대학)
- essay_topics (논술 주제)
- essay_ontology_themes (출제경향 온톨로지)
- nag_nodes, nag_edges (정답 그래프)
- rubrics, rubric_criteria (채점 기준)
- submission_spans (답안 분석)
- graphrag_index (벡터 검색)
- grading_quality_metrics (QWK 품질)
- learning_analytics (학습 분석)

### 게이미피케이션
- missions (미션/도전과제)
- shop_items (상점 아이템)
- coupons (쿠폰/할인)
- analytics_events (분석 이벤트)

### AI 기능
- ai_prompts (AI 프롬프트 템플릿)
- knowledge_nodes (지식 그래프)
- user_patterns (사용자 패턴 분석)
- ai_conversations (AI 대화 기록)

## 🔐 Supabase 설정
- ✅ Pro 플랜 구매 완료
- ✅ 프로젝트 생성 완료 (micro compute size)
- ✅ pgvector 확장 활성화 (임베딩 검색용)
- ⚠️ RLS 정책: Service Key로 우회 중 (추후 설정 필요)
- ✅ 테스트 사용자 11명 생성 완료
- ✅ Admin 계정: admin@hyle.ai.kr / admin123 (2025-08-31 비밀번호 재설정)

## 🛠️ 기술 스택

### Backend (Supabase)
- PostgreSQL Database
- Real-time subscriptions
- Authentication (이메일/소셜)
- Storage for files
- pgvector for AI embeddings (설정 완료!)

### Admin Dashboard (Next.js 15)
- App Router
- TypeScript
- Tailwind CSS + shadcn/ui
- Supabase SSR
- Vercel 배포
- react-grid-layout (대시보드 커스터마이징)

### Mobile App (Flutter)
- Riverpod 상태 관리
- go_router 네비게이션
- Supabase Flutter SDK
- 다중 entry point (dev/test/prod)

### AI/ML Stack (🆕)
- OpenAI text-embedding-3-large (1536차원)
- GPT-4 / Claude-3 (LLM 채점)
- NLI 분류기 (스팬-노드 정렬)
- GraphRAG (문서 검색)

## 🎯 즉시 필요한 작업
1. **인문논술 AI 시스템 구축**
   - Supabase에 010_essay_comprehensive_schema.sql 적용
   - 기출문제 데이터 수집 (3개 대학 × 3년)
   - NAG 에디터 MVP 개발
   - API 엔드포인트 구현

2. **Flutter 앱 Supabase 실제 연동**
3. **학습자 유형 테스트 구현 (16가지 타입)**
4. **AI 튜터 기능 활성화**
5. **Flutter 타입 에러 수정 (약 400개)**

## 📅 프로젝트 타임라인
- 2025-08-23: AWS Amplify → Supabase 마이그레이션
- 2025-08-26: Admin Dashboard MVP 완성, GitHub 저장소 생성
- 2025-08-27: TypeScript 에러 해결, Vercel 배포 준비
- 2025-08-28: Vercel 배포 성공, 환경 변수 안전 처리
- 2025-08-31: Admin Dashboard 완전 작동, 소셜 기능 DB 추가
- 2025-09-02: 인문논술 AI 시스템 설계 완료, 10개 migration 파일 생성
- 다음: 인문논술 데이터 수집 → API 구현 → Flutter 연동

## 📝 생성된 Migration 파일들
```
/supabase/migrations/
├── 001_initial_schema.sql
├── 002_add_columns.sql
├── 003_add_indexes.sql
├── 004_fix_constraints.sql
├── 005_social_features.sql          # 소셜 기능
├── 006_essay_ai_feature.sql         # 논술 AI 기본
├── 007_essay_ai_enhanced.sql        # 논술 AI 고급
├── 008_essay_master_data.sql        # 10개 대학 데이터
├── 009_essay_data_collection_guide.md
└── 010_essay_comprehensive_schema.sql # 통합 스키마
```

## ⚠️ 알려진 이슈
- RLS 정책 미설정 (Service Key로 임시 해결)
- Flutter 타입 에러 약 400개
- 인문논술 기출 데이터 수집 필요
- users 테이블에 last_seen, status 컬럼 추가 필요

## 💡 중요 메모
- Service Key 환경변수명: SUPABASE_SERVICE_KEY (ROLE 아님!)
- GitHub main branch가 production
- Vercel이 push 시 자동 배포
- 로그인 엔드포인트: /api/auth/login-simple (RLS 우회용)
- pgvector 임베딩: OpenAI text-embedding-3-large (1536차원)