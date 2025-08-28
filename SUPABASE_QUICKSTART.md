# 🚀 HYLE Supabase 24시간 출시 가이드

## 🎯 목표: 24시간 내 Supabase 기반 HYLE 에코시스템 출시

### ⏱️ 타임라인

#### Hour 0-2: Supabase 프로젝트 설정
```bash
# 1. supabase.com 가입 및 프로젝트 생성
# 2. 프로젝트 URL과 키 획득
# 3. 데이터베이스 마이그레이션 실행
```

#### Hour 2-4: Admin Dashboard 연결
```bash
# HYLE Admin (.env.local)
NEXT_PUBLIC_SUPABASE_URL=your_project_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_key
```

#### Hour 4-8: Flutter 앱 Supabase 전환
```yaml
# pubspec.yaml
dependencies:
  supabase_flutter: ^2.0.0
  # AWS Amplify 관련 패키지 제거
```

#### Hour 8-12: 테스트 및 디버깅
- 인증 플로우 테스트
- CRUD 작업 검증
- 실시간 기능 확인

#### Hour 12-16: 배포 준비
- Vercel 배포 (Admin)
- Flutter 웹 빌드
- 환경 변수 설정

#### Hour 16-20: 최종 테스트
- E2E 테스트
- 성능 최적화
- 버그 수정

#### Hour 20-24: 출시
- Production 배포
- 모니터링 설정
- 문서 최종화

## 📦 시스템 구조

```
HYLE 에코시스템 (Supabase 기반)
├── Flutter HYLE App (학습자용)
│   ├── 학습 콘텐츠
│   ├── AI 튜터
│   └── 진도 추적
├── HYLE Admin (관리자용)
│   ├── 사용자 관리
│   ├── 콘텐츠 관리
│   └── 분석 대시보드
└── Supabase Backend (단일 백엔드)
    ├── PostgreSQL DB
    ├── Auth
    ├── Realtime
    └── Storage
```

## 🔧 즉시 실행 명령어

### 1. Supabase CLI 설치
```bash
npm install -g supabase
```

### 2. 프로젝트 초기화
```bash
supabase init
supabase link --project-ref your-project-ref
```

### 3. 마이그레이션 실행
```bash
# HYLE Admin 폴더에서
supabase db push ./supabase/migrations/001_initial_schema.sql
```

### 4. Admin Dashboard 실행
```bash
cd hyle-admin
npm install
npm run dev
```

### 5. Flutter 앱 Supabase 설정
```dart
// main.dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  runApp(MyApp());
}
```

## ✅ 체크리스트

### Supabase 설정
- [ ] 프로젝트 생성
- [ ] API 키 획득
- [ ] 데이터베이스 마이그레이션
- [ ] RLS 정책 확인
- [ ] Storage 버킷 생성

### Admin Dashboard
- [ ] 환경 변수 설정
- [ ] API 연결 테스트
- [ ] 인증 플로우 확인
- [ ] CRUD 작업 테스트
- [ ] Vercel 배포

### Flutter App
- [ ] Supabase 패키지 설치
- [ ] AWS 코드 제거
- [ ] 인증 연동
- [ ] 데이터 동기화
- [ ] 웹 빌드 및 배포

## 🚨 주의사항

1. **AWS 완전 제거**
   - AWS Amplify 관련 코드 모두 삭제
   - AWS 설정 파일 제거
   - AWS 문서 업데이트

2. **보안**
   - Service Role Key는 절대 클라이언트에 노출 금지
   - RLS 정책 필수 설정
   - 환경 변수 관리 철저

3. **성능**
   - 인덱스 최적화
   - 쿼리 최적화
   - 실시간 구독 관리

## 📱 빠른 연락처

- Supabase Dashboard: https://app.supabase.com
- Vercel Dashboard: https://vercel.com/dashboard
- 문서: https://supabase.com/docs

## 🎉 출시 준비 완료!

24시간 내 출시를 위한 모든 준비가 완료되었습니다!