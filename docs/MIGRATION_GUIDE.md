# 문서 이동 안내

## 📚 문서가 재구성되었습니다!

기존 문서들이 더 체계적인 구조로 이동했습니다:

### 이동된 문서 위치

| 기존 파일 | 새 위치 |
|----------|---------|
| `AMAZON_Q_DEVELOPMENT_GUIDE.md` | `docs/aws/AMAZON_Q_GUIDE.md` |
| `CROSS_PLATFORM_DEVELOPMENT_GUIDE.md` | `docs/setup/CROSS_PLATFORM_GUIDE.md` |
| `LOCAL_TESTING_GUIDE.md` | `docs/setup/LOCAL_TESTING_GUIDE.md` |
| `TEST_CHECKLIST.md` | `docs/testing/TEST_CHECKLIST.md` |
| `AI_BETA_TESTING_GUIDE.md` | `docs/testing/BETA_GUIDE.md` |
| `DEVELOPMENT_LOG_*.md` | `docs/logs/` |
| AWS 관련 문서들 | `docs/aws/` 폴더로 통합 |
| 디자인 관련 문서들 | `docs/development/DESIGN_SYSTEM.md`로 통합 |

### 유지된 핵심 문서

- `README.md` - 프로젝트 소개
- `CLAUDE.md` - Claude Code 작업 지침
- `PROJECT_STATUS.md` - 프로젝트 현황
- `CLAUDE_PLAN_MODE_GUIDE.md` - 계획 모드 가이드

### 새로운 문서 구조

```
docs/
├── README.md           # 문서 인덱스
├── aws/               # AWS 관련
│   ├── QUICK_START.md
│   ├── DETAILED_SETUP.md
│   └── AMAZON_Q_GUIDE.md
├── setup/             # 개발 환경
│   ├── CROSS_PLATFORM_GUIDE.md
│   └── LOCAL_TESTING_GUIDE.md
├── development/       # 개발 가이드
│   ├── ARCHITECTURE.md
│   └── DESIGN_SYSTEM.md
├── testing/          # 테스트
│   ├── TEST_CHECKLIST.md
│   └── BETA_GUIDE.md
└── logs/             # 개발 로그
```

모든 문서는 [docs/README.md](docs/README.md)에서 찾을 수 있습니다.