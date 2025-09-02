-- =====================================================
-- HYLE Essay AI Feature Schema
-- 인문논술 첨삭 AI 기능
-- =====================================================

-- =====================================================
-- UNIVERSITY DATA (대학 정보)
-- =====================================================

-- Universities (대학 정보)
CREATE TABLE IF NOT EXISTS universities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(100) UNIQUE NOT NULL, -- 연세대, 고려대, 성균관대 등
  name_en VARCHAR(100),
  
  -- 논술 정보
  essay_type VARCHAR(50), -- 인문논술, 인문사회논술, 상경논술 등
  typical_topics TEXT[], -- 주로 나오는 주제들
  difficulty_level INTEGER CHECK (difficulty_level BETWEEN 1 AND 10),
  
  -- 평가 기준
  evaluation_criteria JSONB, -- 학교별 평가 기준
  scoring_rubric JSONB, -- 채점 기준표
  
  -- 메타데이터
  logo_url TEXT,
  website_url TEXT,
  admission_url TEXT,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Essay Topics by University (대학별 논술 주제)
CREATE TABLE IF NOT EXISTS essay_topics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  university_id UUID REFERENCES universities(id) ON DELETE CASCADE,
  
  -- 주제 정보
  year INTEGER NOT NULL,
  exam_type VARCHAR(50), -- 수시, 정시, 모의
  topic_number INTEGER, -- 문제 번호
  
  -- 문제 내용
  title VARCHAR(255),
  question_text TEXT NOT NULL,
  materials TEXT[], -- 제시문들
  requirements TEXT, -- 요구사항
  word_limit INTEGER, -- 글자수 제한
  time_limit INTEGER, -- 시간 제한 (분)
  
  -- 분석 데이터
  topic_category VARCHAR(100), -- 사회, 윤리, 문화, 경제 등
  difficulty_level INTEGER CHECK (difficulty_level BETWEEN 1 AND 10),
  key_concepts TEXT[], -- 핵심 개념들
  
  -- 예시 답안
  sample_answer TEXT,
  sample_score FLOAT,
  grading_notes TEXT,
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- ESSAY ANALYSIS (논술 분석)
-- =====================================================

-- Essay Submissions (제출된 논술)
CREATE TABLE IF NOT EXISTS essay_submissions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  -- 논술 정보
  university_id UUID REFERENCES universities(id),
  topic_id UUID REFERENCES essay_topics(id),
  
  -- 제출 내용
  essay_text TEXT NOT NULL,
  word_count INTEGER,
  submission_time INTEGER, -- 작성 시간 (초)
  
  -- 상태
  status VARCHAR(50) DEFAULT 'submitted', -- submitted, analyzing, completed, reviewed
  is_practice BOOLEAN DEFAULT TRUE,
  
  -- 메타데이터
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- AI Analysis Results (AI 분석 결과)
CREATE TABLE IF NOT EXISTS essay_ai_analysis (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  submission_id UUID REFERENCES essay_submissions(id) ON DELETE CASCADE,
  
  -- 종합 점수
  total_score FLOAT CHECK (total_score >= 0 AND total_score <= 100),
  grade VARCHAR(10), -- A+, A, B+, B, C+, C, D, F
  
  -- 세부 평가
  structure_score FLOAT, -- 구조 점수
  logic_score FLOAT, -- 논리성 점수
  evidence_score FLOAT, -- 근거 활용 점수
  expression_score FLOAT, -- 표현력 점수
  creativity_score FLOAT, -- 창의성 점수
  relevance_score FLOAT, -- 주제 적합성 점수
  
  -- AI 분석 내용
  strengths TEXT[], -- 장점들
  weaknesses TEXT[], -- 약점들
  improvements TEXT[], -- 개선 제안
  
  -- 세부 피드백
  feedback_structure TEXT, -- 구조 피드백
  feedback_logic TEXT, -- 논리 피드백
  feedback_evidence TEXT, -- 근거 피드백
  feedback_expression TEXT, -- 표현 피드백
  
  -- 문장별 분석
  sentence_analysis JSONB, -- [{sentence: "...", issues: [...], suggestions: [...]}]
  
  -- AI 모델 정보
  ai_model VARCHAR(50), -- gpt-4, claude-3 등
  analysis_version VARCHAR(20),
  processing_time INTEGER, -- 분석 시간 (초)
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Essay Patterns (논술 패턴 분석)
CREATE TABLE IF NOT EXISTS essay_patterns (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  university_id UUID REFERENCES universities(id),
  
  -- 패턴 정보
  pattern_type VARCHAR(100), -- 도입부 패턴, 논증 패턴, 결론 패턴 등
  pattern_name VARCHAR(255),
  description TEXT,
  
  -- 패턴 내용
  pattern_template TEXT, -- 패턴 템플릿
  examples TEXT[], -- 예시들
  keywords TEXT[], -- 주요 키워드
  
  -- 평가
  effectiveness_score FLOAT, -- 효과성 점수
  usage_frequency INTEGER, -- 사용 빈도
  success_rate FLOAT, -- 성공률
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- LEARNING & PRACTICE (학습 및 연습)
-- =====================================================

-- Essay Practice Sets (논술 연습 세트)
CREATE TABLE IF NOT EXISTS essay_practice_sets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- 세트 정보
  title VARCHAR(255) NOT NULL,
  description TEXT,
  difficulty_level INTEGER CHECK (difficulty_level BETWEEN 1 AND 10),
  
  -- 대상
  target_universities UUID[], -- 대상 대학들
  target_grade VARCHAR(20), -- 고1, 고2, 고3, N수생
  
  -- 내용
  topics JSONB, -- 연습 주제들
  estimated_time INTEGER, -- 예상 소요 시간 (분)
  
  -- 상태
  is_premium BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Essay Progress (사용자 논술 진행도)
CREATE TABLE IF NOT EXISTS user_essay_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  -- 통계
  total_essays INTEGER DEFAULT 0,
  average_score FLOAT,
  best_score FLOAT,
  improvement_rate FLOAT, -- 향상도
  
  -- 대학별 진행도
  university_progress JSONB, -- {university_id: {essays: 10, avg_score: 85}}
  
  -- 영역별 점수
  avg_structure_score FLOAT,
  avg_logic_score FLOAT,
  avg_evidence_score FLOAT,
  avg_expression_score FLOAT,
  
  -- 학습 데이터
  weak_areas TEXT[], -- 약한 영역들
  strong_areas TEXT[], -- 강한 영역들
  recommended_topics UUID[], -- 추천 연습 주제
  
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- EXPERT FEEDBACK (전문가 피드백)
-- =====================================================

-- Expert Reviewers (전문가 평가자)
CREATE TABLE IF NOT EXISTS expert_reviewers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  
  -- 전문가 정보
  name VARCHAR(100) NOT NULL,
  credentials TEXT, -- 자격/경력
  specialties TEXT[], -- 전문 분야
  universities TEXT[], -- 전문 대학들
  
  -- 평가 통계
  total_reviews INTEGER DEFAULT 0,
  average_rating FLOAT,
  
  -- 상태
  is_active BOOLEAN DEFAULT TRUE,
  is_verified BOOLEAN DEFAULT FALSE,
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Expert Reviews (전문가 리뷰)
CREATE TABLE IF NOT EXISTS expert_reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  submission_id UUID REFERENCES essay_submissions(id) ON DELETE CASCADE,
  reviewer_id UUID REFERENCES expert_reviewers(id),
  
  -- 평가
  score FLOAT CHECK (score >= 0 AND score <= 100),
  grade VARCHAR(10),
  
  -- 피드백
  overall_feedback TEXT,
  detailed_feedback JSONB, -- 상세 피드백
  
  -- 추천사항
  recommendations TEXT[],
  revision_notes TEXT,
  
  -- 상태
  status VARCHAR(50) DEFAULT 'pending', -- pending, completed, disputed
  review_time INTEGER, -- 리뷰 시간 (분)
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- ESSAY TEMPLATES & RESOURCES (템플릿 및 자료)
-- =====================================================

-- Essay Templates (논술 템플릿)
CREATE TABLE IF NOT EXISTS essay_templates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- 템플릿 정보
  name VARCHAR(255) NOT NULL,
  category VARCHAR(100), -- 도입부, 본론, 결론 등
  university_id UUID REFERENCES universities(id),
  
  -- 템플릿 내용
  template_structure TEXT,
  key_phrases TEXT[], -- 핵심 문구들
  transition_words TEXT[], -- 연결어들
  
  -- 사용 가이드
  usage_guide TEXT,
  examples TEXT[],
  dos_and_donts JSONB, -- {dos: [...], donts: [...]}
  
  -- 평가
  effectiveness_rating FLOAT,
  usage_count INTEGER DEFAULT 0,
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Essay Keywords Bank (논술 키워드 은행)
CREATE TABLE IF NOT EXISTS essay_keywords (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- 키워드 정보
  keyword VARCHAR(100) NOT NULL,
  category VARCHAR(100), -- 사회, 윤리, 경제, 문화 등
  
  -- 정의 및 설명
  definition TEXT,
  explanation TEXT,
  related_concepts TEXT[],
  
  -- 사용 예시
  usage_examples TEXT[],
  common_mistakes TEXT[],
  
  -- 대학별 중요도
  university_importance JSONB, -- {university_id: importance_score}
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

CREATE INDEX idx_essay_topics_university ON essay_topics(university_id);
CREATE INDEX idx_essay_topics_year ON essay_topics(year);
CREATE INDEX idx_essay_submissions_user ON essay_submissions(user_id);
CREATE INDEX idx_essay_submissions_status ON essay_submissions(status);
CREATE INDEX idx_essay_ai_analysis_submission ON essay_ai_analysis(submission_id);
CREATE INDEX idx_essay_ai_analysis_score ON essay_ai_analysis(total_score);
CREATE INDEX idx_user_essay_progress_user ON user_essay_progress(user_id);

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================

ALTER TABLE universities ENABLE ROW LEVEL SECURITY;
ALTER TABLE essay_topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE essay_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE essay_ai_analysis ENABLE ROW LEVEL SECURITY;
ALTER TABLE essay_patterns ENABLE ROW LEVEL SECURITY;
ALTER TABLE essay_practice_sets ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_essay_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE expert_reviewers ENABLE ROW LEVEL SECURITY;
ALTER TABLE expert_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE essay_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE essay_keywords ENABLE ROW LEVEL SECURITY;

-- Public read for universities and topics
CREATE POLICY "Public can view universities" ON universities FOR SELECT USING (true);
CREATE POLICY "Public can view essay topics" ON essay_topics FOR SELECT USING (true);
CREATE POLICY "Public can view practice sets" ON essay_practice_sets FOR SELECT USING (is_active = true);

-- Users can manage their own submissions
CREATE POLICY "Users can manage own submissions" ON essay_submissions 
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view own analysis" ON essay_ai_analysis
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM essay_submissions 
      WHERE id = essay_ai_analysis.submission_id 
      AND user_id = auth.uid()
    )
  );

CREATE POLICY "Users can view own progress" ON user_essay_progress
  FOR ALL USING (auth.uid() = user_id);