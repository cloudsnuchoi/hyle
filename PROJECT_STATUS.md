# HYLE 프로젝트 현황 (2025-08-27 업데이트)

## 🚀 최신 진행 상황

### HYLE Admin Dashboard (✅ 배포 준비 완료!)
- ✅ Supabase 연동 완료
- ✅ 인증 시스템 구현 (Service Key 활용)
- ✅ 사용자 관리 실제 데이터 연동
- ✅ 모든 대시보드 페이지 UI 구현
- ✅ GitHub 저장소 생성 및 연동
- ✅ TypeScript 에러 모두 해결 (100개 이상)
- ✅ 로컬 빌드 성공
- ✅ Vercel 배포 준비 완료
- ⏳ 환경 변수 설정 대기 중

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
│   └── CLAUDE.md       # Claude 가이드
│
└── hyle-admin\         # Next.js 관리자 대시보드
    ├── src\            # Next.js 소스 코드
    ├── supabase\       # DB 마이그레이션
    └── .env.local      # 환경 변수

GitHub Repositories:
- https://github.com/cloudsnuchoi/hyle-admin (main branch)
```

## 🔐 Supabase 설정
- ✅ Pro 플랜 구매 완료
- ✅ 프로젝트 생성 완료 (micro compute size)
- ⚠️ RLS 정책: Service Key로 우회 중 (추후 설정 필요)
- ✅ 테스트 사용자 6명 생성 완료
- ✅ Admin 계정: admin@hyle.ai / admin123

## 🛠️ 기술 스택

### Backend (Supabase)
- PostgreSQL Database
- Real-time subscriptions
- Authentication (이메일/소셜)
- Storage for files
- pgvector for AI embeddings (예정)

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

## 📊 데이터베이스 구조
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

### 게이미피케이션
- missions (미션/도전과제)
- shop_items (상점 아이템)
- coupons (쿠폰/할인)
- analytics_events (분석 이벤트)

### AI 기능
- ai_prompts (AI 프롬프트 템플릿)
- knowledge_nodes (지식 그래프 - 예정)
- user_patterns (사용자 패턴 분석 - 예정)
- ai_conversations (AI 대화 기록 - 예정)

## 🎯 즉시 필요한 작업
1. **Vercel 환경 변수 설정** (가장 급함!)
   ```env
   NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key
   SUPABASE_SERVICE_KEY=your_service_key
   ```

2. Admin Dashboard 배포 확인
3. Flutter 앱 Supabase 실제 연동
4. 학습자 유형 테스트 구현 (16가지 타입)
5. AI 튜터 기능 활성화

## 🐛 해결한 이슈들 (2025-08-27)
- ✅ Branch 문제: master → main 변경
- ✅ Next.js 15 API Route 타입: Promise<params> 처리
- ✅ Supabase 타입: Database → any 임시 해결
- ✅ 누락 아이콘: ThumbsUp, Server, Star, Copy 등 추가
- ✅ react-grid-layout 타입 정의 설치
- ✅ count 쿼리: 별도 쿼리로 분리

## ⚠️ 알려진 이슈
- RLS 정책 미설정 (Service Key로 임시 해결)
- Flutter 타입 에러 약 400개
- 일부 mock 데이터 페이지 실제 연동 필요
- users 테이블에 last_seen, status 컬럼 추가 필요

## 📅 프로젝트 타임라인
- 2025-08-23: AWS Amplify → Supabase 마이그레이션
- 2025-08-26: Admin Dashboard MVP 완성, GitHub 저장소 생성
- 2025-08-27: TypeScript 에러 해결, Vercel 배포 준비
- 다음: Flutter 앱 완성 → 앱스토어 출시

## 💡 중요 메모
- Service Key 환경변수명: SUPABASE_SERVICE_KEY (ROLE 아님!)
- GitHub main branch가 production
- Vercel이 push 시 자동 배포
- 로그인 엔드포인트: /api/auth/login-simple (RLS 우회용)