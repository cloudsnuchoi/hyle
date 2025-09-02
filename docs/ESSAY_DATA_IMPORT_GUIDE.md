# 인문논술 실제 데이터 입력 가이드

## 📌 개요

전문가 분석을 기반으로 구축된 데이터베이스에 실제 기출문제 데이터를 입력하는 방법을 안내합니다.

## 🎯 데이터 입력 우선순위

### Phase 1: 기본 데이터 (즉시)
1. **대학 정보** - 이미 입력됨 ✅
2. **피드백 카테고리** - 이미 입력됨 ✅
3. **시험 메타데이터** - 최근 3년 기출

### Phase 2: 핵심 학습 데이터 (1주 내)
1. **실제 기출문제 3개씩** (대학별)
2. **제시문 전문 또는 요약**
3. **공식 채점 기준**
4. **예시 답안**

### Phase 3: AI 학습 데이터 (2주 내)
1. **논리 흐름 분석**
2. **핵심 개념 추출**
3. **자주 하는 실수 패턴**

## 📝 데이터 입력 방법

### 1. 시험 정보 입력

```sql
-- 예시: 연세대 2024 모의논술
INSERT INTO exams (
  university_id,
  year,
  session,
  exam_round,
  exam_type,
  main_theme,
  time_limit,
  exam_date
) VALUES (
  (SELECT university_id FROM universities WHERE name = '연세대학교'),
  2024,
  '모의논술',
  NULL,
  '인문계',
  '인공지능과 인간의 창의성',
  120,
  '2024-05-15'
);
```

### 2. 제시문 입력

```sql
-- 제시문 입력 (저작권 고려 - 요약 권장)
INSERT INTO passages (
  exam_id,
  label,
  passage_type,
  content,
  is_english,
  summary,
  keywords
) VALUES (
  1, -- exam_id
  '가',
  '철학',
  '칸트의 이성 비판에 대한 발췌... (요약)',
  false,
  '인간 이성의 한계와 가능성에 대한 철학적 고찰',
  ARRAY['이성', '비판', '인식론', '칸트']
);
```

### 3. 문항 입력

```sql
-- 문항 정보
INSERT INTO questions (
  exam_id,
  question_number,
  question_type,
  prompt,
  points,
  word_limit_min,
  word_limit_max,
  cognitive_level,
  task_category
) VALUES (
  1,
  1,
  '분류-요약',
  '제시문 (가)~(라)를 두 가지 입장으로 분류하고, 각 입장을 요약하시오.',
  30,
  400,
  600,
  '분석',
  '비교형'
);
```

### 4. 문항-제시문 연결

```sql
-- 문항과 제시문 연결
INSERT INTO question_passage_link (
  question_id,
  passage_id,
  usage_type,
  sequence_order
) VALUES
  (1, 1, '필수', 1),
  (1, 2, '필수', 2),
  (1, 3, '필수', 3),
  (1, 4, '필수', 4);
```

### 5. 공식 해설 입력 (가장 중요!)

```sql
-- AI 학습의 핵심 데이터
INSERT INTO official_analyses (
  question_id,
  intent,
  evaluation_focus,
  model_answer,
  scoring_rubric,
  logical_flow,
  key_concepts,
  common_mistakes
) VALUES (
  1,
  '상반된 철학적 입장을 정확히 파악하고 체계적으로 분류하는 능력 평가',
  ARRAY['분류의 정확성', '요약의 충실성', '논리적 구성'],
  '제시문들은 크게 두 입장으로 나뉜다. 첫째, (가)와 (다)는... 둘째, (나)와 (라)는...',
  '{
    "분류정확성": {"상": "90-100", "중": "70-89", "하": "0-69"},
    "요약충실성": {"상": "90-100", "중": "70-89", "하": "0-69"},
    "논리구성": {"상": "90-100", "중": "70-89", "하": "0-69"}
  }'::JSONB,
  '{
    "step1": "제시문 핵심 논지 파악",
    "step2": "공통점과 차이점 분석", 
    "step3": "분류 기준 설정",
    "step4": "각 입장 요약"
  }'::JSONB,
  ARRAY['이성주의', '경험주의', '인식론', '형이상학'],
  ARRAY['분류 기준 불명확', '제시문 오독', '요약 시 핵심 누락']
);
```

## 🔧 데이터 수집 도구

### CSV 임포트 템플릿

`essay_data_template.csv`:
```csv
university_name,year,session,question_number,prompt,passage_labels,model_answer
연세대학교,2024,모의논술,1,"제시문을 분류하시오","가,나,다,라","모범답안..."
```

### Python 스크립트 예시

```python
import pandas as pd
from supabase import create_client

# CSV 읽기
df = pd.read_csv('essay_data_template.csv')

# Supabase 연결
supabase = create_client(url, key)

# 데이터 입력
for _, row in df.iterrows():
    # 시험 정보 입력
    exam = supabase.table('exams').insert({
        'university_id': get_university_id(row['university_name']),
        'year': row['year'],
        'session': row['session']
    }).execute()
    
    # 문항 정보 입력
    question = supabase.table('questions').insert({
        'exam_id': exam.data[0]['exam_id'],
        'question_number': row['question_number'],
        'prompt': row['prompt']
    }).execute()
```

## ⚠️ 주의사항

### 저작권
- 기출문제 원문 전체 저장 금지
- 제시문은 요약 또는 출처만 기록
- 학생 공개 전 대학 허가 확인

### 데이터 품질
- 공식 출처(대학 입학처) 우선
- 오타 및 형식 통일성 검증
- 채점 기준 정확성 확인

### 개인정보
- 실제 학생 답안 사용 시 동의 필수
- 익명화 처리 필수

## 📊 데이터 검증 쿼리

```sql
-- 입력된 데이터 확인
SELECT 
  u.name as 대학,
  COUNT(DISTINCT e.exam_id) as 시험수,
  COUNT(DISTINCT q.question_id) as 문항수,
  COUNT(DISTINCT oa.analysis_id) as 해설수
FROM universities u
LEFT JOIN exams e ON u.university_id = e.university_id
LEFT JOIN questions q ON e.exam_id = q.exam_id
LEFT JOIN official_analyses oa ON q.question_id = oa.question_id
GROUP BY u.name
ORDER BY u.name;
```

## 🚀 다음 단계

1. **데이터 수집팀 구성**
   - 대학별 담당자 지정
   - 기출문제 PDF 수집

2. **데이터 정제**
   - OCR로 텍스트 추출
   - 구조화된 형식으로 변환

3. **품질 검증**
   - 전문가 검수
   - 테스트 채점 실행

4. **지속적 업데이트**
   - 매년 신규 기출 추가
   - 채점 기준 개선