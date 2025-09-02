# 개발 메모리: 2025-09-02 인문논술 AI 시스템 구축

## 📅 세션 정보
- **날짜**: 2025년 9월 2일
- **프로젝트**: HYLE (Flutter) + HYLE-Admin (Next.js)
- **주요 작업**: 인문논술 AI 채점 시스템 데이터베이스 설계 및 구축

## 🎯 주요 성과

### 1. 인문논술 AI 시스템 전체 설계 완료
- 온톨로지 + GraphRAG 기반 채점 시스템 설계
- NAG (Normative Answer Graph) 정답 그래프 구조 설계
- 채점 파이프라인 7단계 설계 (프리체크 → LLM 합의 채점 → 코칭 피드백)

### 2. 데이터베이스 스키마 구축 (10개 파일 생성)

#### 기본 구조
- `006_essay_ai_feature.sql`: 기본 테이블 구조
  - universities, essay_topics, essay_submissions
  - essay_ai_analysis, expert_reviews
  - essay_templates, essay_keywords

#### 고급 기능
- `007_essay_ai_enhanced.sql`: 온톨로지 & GraphRAG 시스템
  - essay_ontology_themes: 출제경향 온톨로지
  - nag_nodes, nag_edges: 정답 그래프
  - graphrag_index: 벡터 검색 (pgvector)
  - submission_spans, span_alignment: 채점 파이프라인
  - grading_quality_metrics: QWK 품질 지표

#### 마스터 데이터
- `008_essay_master_data.sql`: 10개 대학 기본 정보
  - 연세대, 고려대, 성균관대, 한양대, 서강대
  - 중앙대, 경희대, 한국외대, 서울시립대, 건국대

#### 가이드 문서
- `009_essay_data_collection_guide.md`: 데이터 수집 가이드
- `ESSAY_DATA_IMPORT_GUIDE.md`: 실제 데이터 입력 방법

### 3. 전문가 분석 기반 통합 스키마
- `010_essay_comprehensive_schema.sql`: 완전히 새로운 통합 스키마
  - 15개 핵심 테이블
  - 대학별 논술 유형 분류 (4가지 유형)
  - PostgreSQL + pgvector 최적화
  - Row Level Security 적용

## 📊 대학별 논술 유형 분류 (전문가 분석)

### 유형 1: 정형화된 연계형
- 성균관대, 한국외대, 한양대
- 3단계 구조: 분류-요약 → 자료해석-평가 → 견해-논증

### 유형 2: 통합 서술형
- 서강대, 서울시립대
- 하나의 통합 논제로 완결된 글 작성

### 유형 3: 복합 과제형
- 경희대, 중앙대, 건국대
- 2-3개 독립 논제, 다양한 사고 능력 측정

### 유형 4: 융합 심층형
- 연세대, 고려대
- 영어 제시문, 수리적 자료 포함
- 고차원적 추론 능력 요구

## 🔧 기술 스택

### 데이터베이스
- **Supabase** (PostgreSQL)
- **pgvector**: OpenAI text-embedding-3-large (1536차원)
- **한국어 전문 검색**: to_tsvector('korean')
- **JSONB**: 구조화된 채점 기준, 논리 흐름

### AI/ML 컴포넌트
- **임베딩**: OpenAI text-embedding-3-large
- **LLM 채점**: GPT-4, Claude-3
- **NLI 분류기**: 스팬-노드 정렬
- **GraphRAG**: 루브릭, NAG 노드 검색

## 📝 채점 파이프라인

1. **프리체크**: 글자수, 문단수, 금칙어
2. **텍스트 세분화**: 문장/문단 분할, 담화 역할 태깅
3. **NAG 정렬**: 스팬 ↔ 노드 NLI + 임베딩 유사도
4. **기준별 점수**: 루브릭 가중치 × 정합도
5. **LLM 합의 채점**: 3회 독립 평가 → 중위수
6. **검증기**: 제시문 근거 하이라이트, 오독 탐지
7. **코칭 피드백**: JSON Schema 기반 구조화

## 🚀 다음 단계

### 즉시 (Phase 1)
- [ ] Supabase에 스키마 적용
- [ ] 기출문제 3개 대학 × 3년치 수집
- [ ] NAG 에디터 MVP 개발

### 1주 내 (Phase 2)
- [ ] GraphRAG 인덱싱 파이프라인
- [ ] LLM 채점 프롬프트 v1
- [ ] 프리체크/세분화/정렬 구현

### 2주 내 (Phase 3)
- [ ] 합의 채점 시스템
- [ ] QWK 모니터링 대시보드
- [ ] 모의문항 생성 워크플로우

## 💡 핵심 인사이트

1. **대학별 맞춤 채점**: 각 대학의 고유한 평가 기준 반영
2. **다층적 분석**: 논리 흐름, 제시문 활용도, 인지 수준
3. **Ground Truth 중심**: official_analyses 테이블이 AI 학습의 핵심
4. **RLHF 준비**: 사용자 평가 → AI 개선 순환 구조

## 📁 생성된 파일 목록

```
/supabase/migrations/
├── 006_essay_ai_feature.sql
├── 007_essay_ai_enhanced.sql
├── 008_essay_master_data.sql
├── 009_essay_data_collection_guide.md
└── 010_essay_comprehensive_schema.sql

/docs/
└── ESSAY_DATA_IMPORT_GUIDE.md

/ref/
├── 인문논술1 (PRD 분석)
└── 인문논술2 (상세 스키마)
```

## 🔗 참고 자료
- PRD: `/ref/인문논술1`, `/ref/인문논술2`
- 전문가 분석: 한국 대입 인문논술 유형화 및 평가 기준

## ✅ 완료 상태
- 데이터베이스 설계: 100% 완료
- 스키마 생성: 100% 완료
- 문서화: 100% 완료
- Supabase 적용: 대기 중
- Flutter 연동: 대기 중