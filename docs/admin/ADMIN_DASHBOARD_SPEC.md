# Hyle Admin Dashboard Specification

## 📋 개요

### 프로젝트 정보
- **프로젝트명**: Hyle Admin Dashboard
- **목적**: Hyle 학습 플랫폼의 운영, 관리, 모니터링을 위한 관리자 전용 대시보드
- **기술 스택**: Next.js 14, TypeScript, Tailwind CSS, Supabase
- **도메인**: admin.hyle.ai (예정)

### 핵심 목표
1. 실시간 사용자 및 시스템 모니터링
2. 효율적인 콘텐츠 및 사용자 관리
3. AI 시스템 설정 및 최적화
4. 데이터 기반 의사결정 지원

## 🏗️ 시스템 아키텍처

```
┌─────────────────────────────────────────┐
│         Admin Dashboard (Next.js)        │
│                                         │
│  ┌──────────────┬────────────────────┐ │
│  │   Frontend   │     Middleware      │ │
│  │  React/Next  │   Auth/Security     │ │
│  └──────────────┴────────────────────┘ │
└────────────────┬───────────────────────┘
                 │
        ┌────────▼────────┐
        │    Supabase     │
        │   (Backend)     │
        └─────────────────┘
```

## 👥 사용자 역할 및 권한

### 역할 정의
1. **Super Admin**
   - 모든 권한
   - 시스템 설정 변경
   - 관리자 계정 관리

2. **Admin**
   - 사용자 관리
   - 콘텐츠 관리
   - 모니터링

3. **Moderator**
   - 콘텐츠 검토
   - 사용자 지원
   - 읽기 전용 분석

### 권한 매트릭스
| 기능 | Super Admin | Admin | Moderator |
|------|-------------|-------|-----------|
| 사용자 관리 | ✅ | ✅ | ❌ |
| 콘텐츠 CRUD | ✅ | ✅ | ⚠️ (검토만) |
| AI 설정 | ✅ | ❌ | ❌ |
| 시스템 설정 | ✅ | ❌ | ❌ |
| 분석 보기 | ✅ | ✅ | ✅ |

## 📊 주요 기능

### 1. 대시보드 홈
- **주요 지표 카드**
  - 총 사용자 수
  - 일일 활성 사용자 (DAU)
  - 월간 활성 사용자 (MAU)
  - 매출 현황
  - AI API 사용량

- **실시간 모니터링**
  - 현재 접속자 수
  - 서버 상태
  - 에러 로그
  - 시스템 리소스

- **차트 및 그래프**
  - 사용자 증가 추세
  - 학습 시간 통계
  - 인기 콘텐츠 순위

### 2. 사용자 관리

#### 2.1 사용자 목록
- 검색 및 필터링
  - 이메일, 이름
  - 가입일, 최근 접속
  - 구독 상태
  - 학습 레벨

- 대량 작업
  - 계정 활성화/비활성화
  - 이메일 발송
  - 구독 변경

#### 2.2 사용자 상세
- 프로필 정보
- 학습 기록 및 통계
- 결제 내역
- 활동 로그
- 지원 티켓

### 3. 콘텐츠 관리

#### 3.1 퀘스트/미션
- CRUD 작업
- 카테고리 관리
- 보상 설정
- 스케줄링

#### 3.2 학습 콘텐츠
- 문제 은행 관리
- 커리큘럼 편집
- 난이도 조정

### 4. AI 시스템 관리

#### 4.1 프롬프트 엔지니어링
- 시스템 프롬프트 관리
- 응답 템플릿
- A/B 테스트

#### 4.2 사용량 모니터링
- OpenAI API 사용량
- 토큰 소비 통계
- 비용 분석
- Rate Limit 관리

### 5. 비즈니스 인텔리전스

#### 5.1 사용자 분석
- 리텐션 분석
- 코호트 분석
- 사용자 행동 패턴
- 이탈 예측

#### 5.2 매출 분석
- 구독 현황
- 결제 통계
- 환불 처리
- 수익 예측

### 6. 시스템 설정

#### 6.1 앱 설정
- 기능 플래그
- 유지보수 모드
- 알림 설정

#### 6.2 보안 설정
- API 키 관리
- 접근 로그
- 보안 정책

## 💾 데이터베이스 스키마

### 관리자 테이블
```sql
-- 관리자 사용자
CREATE TABLE admin_users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  name TEXT,
  role TEXT CHECK (role IN ('super_admin', 'admin', 'moderator')),
  permissions JSONB DEFAULT '{}',
  last_login TIMESTAMP,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 감사 로그
CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  admin_id UUID REFERENCES admin_users(id),
  action TEXT NOT NULL,
  target_type TEXT,
  target_id UUID,
  changes JSONB,
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 시스템 설정
CREATE TABLE system_settings (
  key TEXT PRIMARY KEY,
  value JSONB NOT NULL,
  description TEXT,
  updated_by UUID REFERENCES admin_users(id),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 공지사항
CREATE TABLE announcements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  type TEXT CHECK (type IN ('info', 'warning', 'maintenance', 'update')),
  target_audience TEXT[] DEFAULT ARRAY['all'],
  is_active BOOLEAN DEFAULT true,
  start_date TIMESTAMP,
  end_date TIMESTAMP,
  created_by UUID REFERENCES admin_users(id),
  created_at TIMESTAMP DEFAULT NOW()
);

-- 대시보드 위젯 설정
CREATE TABLE dashboard_widgets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  admin_id UUID REFERENCES admin_users(id),
  widget_type TEXT NOT NULL,
  position JSONB NOT NULL,
  settings JSONB DEFAULT '{}',
  is_visible BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);
```

## 🎨 UI/UX 디자인

### 디자인 원칙
1. **명확성**: 정보 계층 구조 명확
2. **효율성**: 최소 클릭으로 작업 완료
3. **일관성**: 통일된 디자인 시스템
4. **반응형**: 모든 디바이스 지원

### 컴포넌트 라이브러리
- **shadcn/ui**: 기본 UI 컴포넌트
- **Recharts**: 차트 및 그래프
- **Lucide Icons**: 아이콘
- **React Table**: 데이터 테이블

### 색상 팔레트
```css
--primary: #6366f1;     /* Indigo */
--secondary: #8b5cf6;   /* Purple */
--success: #10b981;     /* Green */
--warning: #f59e0b;     /* Amber */
--danger: #ef4444;      /* Red */
--neutral: #6b7280;     /* Gray */
```

## 🔐 보안

### 인증 및 권한
- Supabase Auth 사용
- JWT 토큰 기반 인증
- Role-Based Access Control (RBAC)
- 2FA 지원 (선택)

### 보안 정책
- HTTPS 필수
- CORS 설정
- Rate Limiting
- SQL Injection 방지
- XSS 방지

## 📈 성능 최적화

### 프론트엔드
- Next.js 14 App Router
- React Server Components
- 이미지 최적화
- 코드 스플리팅
- 캐싱 전략

### 백엔드
- 데이터베이스 인덱싱
- 쿼리 최적화
- 실시간 구독 관리
- 페이지네이션

## 🚀 배포

### 환경 구성
- **개발**: localhost:3001
- **스테이징**: staging-admin.hyle.ai
- **프로덕션**: admin.hyle.ai

### 배포 플랫폼
- **Vercel**: Next.js 호스팅
- **Supabase**: 백엔드 서비스
- **Cloudflare**: CDN

## 📅 개발 로드맵

### Phase 1: MVP (Week 1)
- [x] 프로젝트 설정
- [ ] 인증 시스템
- [ ] 기본 대시보드
- [ ] 사용자 목록

### Phase 2: 핵심 기능 (Week 2)
- [ ] 사용자 상세 관리
- [ ] 콘텐츠 CRUD
- [ ] 실시간 모니터링

### Phase 3: 고급 기능 (Week 3)
- [ ] AI 설정 관리
- [ ] 비즈니스 분석
- [ ] 시스템 설정

### Phase 4: 최적화 (Week 4)
- [ ] 성능 최적화
- [ ] 보안 강화
- [ ] 배포 준비

## 📚 기술 문서

### API 엔드포인트
```typescript
// 사용자 관리
GET    /api/admin/users
GET    /api/admin/users/:id
PUT    /api/admin/users/:id
DELETE /api/admin/users/:id

// 콘텐츠 관리
GET    /api/admin/content
POST   /api/admin/content
PUT    /api/admin/content/:id
DELETE /api/admin/content/:id

// 분석
GET    /api/admin/analytics/overview
GET    /api/admin/analytics/users
GET    /api/admin/analytics/revenue
```

### 환경 변수
```env
# Supabase
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_KEY=

# Authentication
NEXTAUTH_SECRET=
NEXTAUTH_URL=

# External APIs
OPENAI_API_KEY=

# Analytics
GOOGLE_ANALYTICS_ID=
```

## 🧪 테스트

### 테스트 전략
- 단위 테스트: Jest
- 통합 테스트: Cypress
- E2E 테스트: Playwright

### 테스트 커버리지 목표
- 유틸리티 함수: 90%
- API 엔드포인트: 80%
- UI 컴포넌트: 70%

## 📞 지원 및 문서

### 개발자 문서
- API 문서: `/docs/api`
- 컴포넌트 문서: Storybook
- 배포 가이드: `/docs/deployment`

### 관리자 매뉴얼
- 사용자 가이드
- FAQ
- 트러블슈팅

---

**작성일**: 2025-08-23
**작성자**: Claude Code + 개발팀
**버전**: 1.0.0