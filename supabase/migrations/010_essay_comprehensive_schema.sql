-- =====================================================
-- Comprehensive Essay Grading Database Schema
-- 한국 대입 인문논술 AI 채점 시스템 통합 스키마
-- Based on Expert Analysis of Korean University Essay Exams
-- =====================================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "vector";

-- =====================================================
-- 1. Universities (대학 정보)
-- =====================================================
CREATE TABLE IF NOT EXISTS universities (
  university_id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE, -- 대학명
  name_en VARCHAR(100), -- 영문 대학명
  university_type VARCHAR(50), -- 대학 유형: 정형화된 연계형, 통합 서술형, 복합 과제형, 융합 심층형
  essay_style TEXT, -- 논술 특징 설명
  typical_structure TEXT, -- 전형적인 문제 구조
  emphasis_points JSONB, -- 강조점: {"논리성": 35, "창의성": 20, ...}
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP, -- 생성일시
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP -- 수정일시
);

COMMENT ON TABLE universities IS '대학별 논술 특성 정보';
COMMENT ON COLUMN universities.university_type IS '정형화된 연계형, 통합 서술형, 복합 과제형, 융합 심층형';

-- =====================================================
-- 2. Exams (시험 정보)
-- =====================================================
CREATE TABLE IF NOT EXISTS exams (
  exam_id SERIAL PRIMARY KEY,
  university_id INTEGER NOT NULL REFERENCES universities(university_id) ON DELETE CASCADE, -- 대학 ID
  year INTEGER NOT NULL, -- 시행 연도
  session VARCHAR(50) NOT NULL, -- 시험 구분: 모의논술, 수시, 정시
  exam_round VARCHAR(50), -- 상세 구분: 오전, 오후, 1교시, 2교시
  exam_type VARCHAR(50), -- 계열: 인문계, 사회계, 상경계
  main_theme TEXT, -- 시험 전체 주제
  time_limit INTEGER, -- 제한 시간(분)
  total_points INTEGER DEFAULT 100, -- 총점
  exam_date DATE, -- 시험 일자
  pdf_url TEXT, -- 원본 PDF URL
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP -- 생성일시
);

COMMENT ON TABLE exams IS '논술 시험 세션 정보';
COMMENT ON COLUMN exams.session IS '모의논술, 수시, 정시 등';

-- =====================================================
-- 3. Passages (제시문 정보)
-- =====================================================
CREATE TABLE IF NOT EXISTS passages (
  passage_id SERIAL PRIMARY KEY,
  exam_id INTEGER NOT NULL REFERENCES exams(exam_id) ON DELETE CASCADE, -- 시험 ID
  label VARCHAR(20) NOT NULL, -- 제시문 라벨: 가, 나, 다, <자료1>, <표1>
  passage_type VARCHAR(50), -- 제시문 유형: 문학, 철학, 사회과학, 통계자료, 영어, 그래프
  content TEXT NOT NULL, -- 제시문 전문 또는 요약
  source_info TEXT, -- 출처 정보
  is_english BOOLEAN DEFAULT FALSE, -- 영어 제시문 여부
  is_numerical BOOLEAN DEFAULT FALSE, -- 수리/통계 자료 여부
  summary TEXT, -- 핵심 논지 요약
  keywords TEXT[], -- 핵심 개념어 배열
  embedding vector(1536), -- 텍스트 임베딩 (OpenAI text-embedding-3-large)
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP -- 생성일시
);

COMMENT ON TABLE passages IS '제시문 정보 저장';
COMMENT ON COLUMN passages.embedding IS 'OpenAI text-embedding-3-large 벡터';

-- =====================================================
-- 4. Questions (문항 정보)
-- =====================================================
CREATE TABLE IF NOT EXISTS questions (
  question_id SERIAL PRIMARY KEY,
  exam_id INTEGER NOT NULL REFERENCES exams(exam_id) ON DELETE CASCADE, -- 시험 ID
  question_number INTEGER NOT NULL, -- 문항 번호
  question_type VARCHAR(100), -- 문제 유형: 분류-요약, 비교-평가, 자료해석-평가, 적용-추론, 견해-논증, 통합논술
  prompt TEXT NOT NULL, -- 발문 전문
  requirements TEXT[], -- 세부 요구사항 배열
  points INTEGER, -- 배점
  recommended_length INTEGER, -- 권장 글자수
  word_limit_min INTEGER, -- 최소 글자수
  word_limit_max INTEGER, -- 최대 글자수
  cognitive_level VARCHAR(50), -- 인지 수준: 이해, 분석, 평가, 창출 (Bloom's Taxonomy)
  task_category VARCHAR(50), -- 과제 범주: 비교형, 논증형, 비판형, 적용형, 종합형
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP -- 생성일시
);

COMMENT ON TABLE questions IS '문항별 정보';
COMMENT ON COLUMN questions.question_type IS '분류-요약, 비교-평가, 자료해석, 적용-추론 등';

-- =====================================================
-- 5. Question_Passage_Link (문항-제시문 연결)
-- =====================================================
CREATE TABLE IF NOT EXISTS question_passage_link (
  link_id SERIAL PRIMARY KEY,
  question_id INTEGER NOT NULL REFERENCES questions(question_id) ON DELETE CASCADE, -- 문항 ID
  passage_id INTEGER NOT NULL REFERENCES passages(passage_id) ON DELETE CASCADE, -- 제시문 ID
  usage_type VARCHAR(50), -- 활용 유형: 필수, 선택, 참고
  sequence_order INTEGER, -- 제시문 순서
  UNIQUE(question_id, passage_id)
);

COMMENT ON TABLE question_passage_link IS '문항과 제시문 간 다대다 관계';
COMMENT ON COLUMN question_passage_link.usage_type IS '필수, 선택, 참고 등';

-- =====================================================
-- 6. Official_Analyses (공식 해설 및 채점 기준)
-- =====================================================
CREATE TABLE IF NOT EXISTS official_analyses (
  analysis_id SERIAL PRIMARY KEY,
  question_id INTEGER NOT NULL UNIQUE REFERENCES questions(question_id) ON DELETE CASCADE, -- 문항 ID
  intent TEXT, -- 출제 의도
  evaluation_focus TEXT[], -- 평가 중점: ["논리적 구성", "제시문 활용", "창의적 해석"]
  model_answer TEXT, -- 예시 답안 전문
  model_answer_structure JSONB, -- 예시 답안 구조 분석
  scoring_rubric JSONB NOT NULL, -- 채점 기준표
  logical_flow JSONB, -- 이상적 논리 전개: {"step1": "현상 파악", "step2": "관계 분석", ...}
  key_concepts TEXT[], -- 필수 포함 개념
  common_mistakes TEXT[], -- 자주 하는 실수
  grading_notes TEXT, -- 채점 유의사항
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP -- 생성일시
);

COMMENT ON TABLE official_analyses IS 'AI 학습용 정답 데이터 (Ground Truth)';
COMMENT ON COLUMN official_analyses.scoring_rubric IS '{"논리성": {"상": "90-100", "중": "70-89", "하": "0-69"}, ...}';

-- =====================================================
-- 7. Users (사용자 정보)
-- =====================================================
CREATE TABLE IF NOT EXISTS users (
  user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email VARCHAR(255) UNIQUE NOT NULL, -- 이메일
  username VARCHAR(100), -- 사용자명
  grade VARCHAR(20), -- 학년: 고1, 고2, 고3, N수생
  target_universities INTEGER[], -- 목표 대학 ID 배열
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP, -- 가입일시
  last_login TIMESTAMP WITH TIME ZONE -- 마지막 로그인
);

COMMENT ON TABLE users IS '학생 사용자 정보';
COMMENT ON COLUMN users.target_universities IS '목표 대학 ID 목록';

-- =====================================================
-- 8. Student_Submissions (학생 답안)
-- =====================================================
CREATE TABLE IF NOT EXISTS student_submissions (
  submission_id SERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE, -- 학생 ID
  question_id INTEGER NOT NULL REFERENCES questions(question_id) ON DELETE CASCADE, -- 문항 ID
  submission_text TEXT NOT NULL, -- 답안 전문
  word_count INTEGER, -- 글자수
  paragraph_count INTEGER, -- 문단수
  submission_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP, -- 제출일시
  time_spent INTEGER, -- 작성 시간(초)
  is_final BOOLEAN DEFAULT FALSE, -- 최종 제출 여부
  version INTEGER DEFAULT 1 -- 답안 버전 (리비전 추적)
);

COMMENT ON TABLE student_submissions IS '학생 제출 답안';
COMMENT ON COLUMN student_submissions.version IS '수정 버전 추적';

-- =====================================================
-- 9. AI_Feedbacks (AI 첨삭 결과)
-- =====================================================
CREATE TABLE IF NOT EXISTS ai_feedbacks (
  feedback_id SERIAL PRIMARY KEY,
  submission_id INTEGER NOT NULL REFERENCES student_submissions(submission_id) ON DELETE CASCADE, -- 답안 ID
  overall_score NUMERIC(5,2), -- 총점
  rubric_scores JSONB NOT NULL, -- 항목별 점수: {"논리성": 85, "표현력": 70, ...}
  grade VARCHAR(10), -- 등급: A+, A, B+, B, C
  feedback_summary TEXT, -- 총평
  strengths TEXT[], -- 잘한 점
  weaknesses TEXT[], -- 개선점
  detailed_feedback JSONB, -- 상세 피드백: [{"paragraph": 1, "comment": "...", "suggestion": "..."}]
  missing_concepts TEXT[], -- 누락된 핵심 개념
  passage_utilization JSONB, -- 제시문 활용도: {"가": 80, "나": 60, ...}
  logical_flow_analysis JSONB, -- 논리 전개 분석
  ai_model VARCHAR(50), -- 사용 AI 모델: gpt-4, claude-3
  confidence_score NUMERIC(3,2), -- AI 확신도: 0.00 ~ 1.00
  processing_time INTEGER, -- 처리 시간(초)
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP -- 생성일시
);

COMMENT ON TABLE ai_feedbacks IS 'AI가 생성한 첨삭 결과';
COMMENT ON COLUMN ai_feedbacks.detailed_feedback IS '[{"paragraph": 1, "sentences": [...], "issues": [...]}]';

-- =====================================================
-- 10. Feedback_Ratings (피드백 평가)
-- =====================================================
CREATE TABLE IF NOT EXISTS feedback_ratings (
  rating_id SERIAL PRIMARY KEY,
  feedback_id INTEGER NOT NULL REFERENCES ai_feedbacks(feedback_id) ON DELETE CASCADE, -- 피드백 ID
  user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE, -- 평가자 ID
  usefulness INTEGER CHECK (usefulness BETWEEN 1 AND 5), -- 유용성: 1-5점
  accuracy INTEGER CHECK (accuracy BETWEEN 1 AND 5), -- 정확성: 1-5점
  clarity INTEGER CHECK (clarity BETWEEN 1 AND 5), -- 명확성: 1-5점
  overall_rating INTEGER CHECK (overall_rating BETWEEN 1 AND 5), -- 전체 평점
  comments TEXT, -- 추가 의견
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP, -- 평가일시
  UNIQUE(feedback_id, user_id)
);

COMMENT ON TABLE feedback_ratings IS 'AI 피드백에 대한 사용자 평가 (RLHF용)';
COMMENT ON COLUMN feedback_ratings.usefulness IS '피드백의 실질적 도움 정도';

-- =====================================================
-- 11. Feedback_Categories (피드백 카테고리)
-- =====================================================
CREATE TABLE IF NOT EXISTS feedback_categories (
  category_id SERIAL PRIMARY KEY,
  category_code VARCHAR(50) UNIQUE NOT NULL, -- 카테고리 코드: LOGIC_ERROR, EVIDENCE_LACK
  category_name VARCHAR(100) NOT NULL, -- 카테고리명: 논리 오류, 근거 부족
  description TEXT, -- 상세 설명
  severity_level INTEGER CHECK (severity_level BETWEEN 1 AND 5), -- 심각도: 1(경미) ~ 5(심각)
  typical_deduction INTEGER, -- 일반적 감점
  improvement_tips TEXT[], -- 개선 팁
  example_cases TEXT[], -- 예시 사례
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP -- 생성일시
);

COMMENT ON TABLE feedback_categories IS '표준화된 피드백 유형 분류';
COMMENT ON COLUMN feedback_categories.severity_level IS '1(경미) ~ 5(심각)';

-- =====================================================
-- 12. Learning_Resources (학습 자료)
-- =====================================================
CREATE TABLE IF NOT EXISTS learning_resources (
  resource_id SERIAL PRIMARY KEY,
  resource_type VARCHAR(50) NOT NULL, -- 자료 유형: article, video, exercise, example
  title VARCHAR(255) NOT NULL, -- 제목
  content TEXT, -- 내용 (article인 경우)
  url TEXT, -- 외부 링크 (video인 경우)
  category VARCHAR(100), -- 분류: 논리학, 철학개념, 작문기법, 자료해석
  target_weakness VARCHAR(100), -- 대상 약점: 논리비약, 근거부족, 구성산만
  difficulty_level INTEGER CHECK (difficulty_level BETWEEN 1 AND 5), -- 난이도
  estimated_time INTEGER, -- 예상 학습 시간(분)
  keywords TEXT[], -- 키워드
  view_count INTEGER DEFAULT 0, -- 조회수
  usefulness_score NUMERIC(3,2), -- 유용성 점수: 0.00 ~ 5.00
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP, -- 생성일시
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP -- 수정일시
);

COMMENT ON TABLE learning_resources IS '학습 자료 저장소';
COMMENT ON COLUMN learning_resources.target_weakness IS '이 자료가 개선하는 약점 유형';

-- =====================================================
-- Additional Tables for Advanced Features
-- =====================================================

-- 13. Question_Themes (문항 주제 분류)
CREATE TABLE IF NOT EXISTS question_themes (
  theme_id SERIAL PRIMARY KEY,
  question_id INTEGER NOT NULL REFERENCES questions(question_id) ON DELETE CASCADE,
  theme_category VARCHAR(100), -- 주제 범주: 사회, 윤리, 문화, 경제, 정치, 철학, 과학, 환경
  theme_name VARCHAR(255), -- 세부 주제: 개인과 공동체, 정의와 평등, 기술과 인간
  keywords TEXT[], -- 관련 키워드
  UNIQUE(question_id, theme_category)
);

COMMENT ON TABLE question_themes IS '문항별 주제 분류 (출제경향 분석용)';

-- 14. Student_Progress (학생 진행도 추적)
CREATE TABLE IF NOT EXISTS student_progress (
  progress_id SERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  university_id INTEGER REFERENCES universities(university_id),
  total_submissions INTEGER DEFAULT 0, -- 총 제출 수
  average_score NUMERIC(5,2), -- 평균 점수
  improvement_rate NUMERIC(5,2), -- 향상도
  strength_areas JSONB, -- 강점 영역: {"논리성": 85, "창의성": 90}
  weakness_areas JSONB, -- 약점 영역: {"근거활용": 60, "구성": 65}
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, university_id)
);

COMMENT ON TABLE student_progress IS '학생별 학습 진행도 및 통계';

-- 15. Mock_Questions (AI 생성 모의문항)
CREATE TABLE IF NOT EXISTS mock_questions (
  mock_id SERIAL PRIMARY KEY,
  based_on_university_id INTEGER REFERENCES universities(university_id),
  generated_theme VARCHAR(255), -- 생성된 주제
  difficulty_level INTEGER CHECK (difficulty_level BETWEEN 1 AND 10),
  prompt TEXT NOT NULL, -- 생성된 문제
  passages JSONB, -- 생성된 제시문들
  model_answer TEXT, -- 생성된 모범답안
  generation_params JSONB, -- 생성 파라미터
  quality_score NUMERIC(3,2), -- 품질 점수
  is_verified BOOLEAN DEFAULT FALSE, -- 검증 여부
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE mock_questions IS 'AI가 생성한 모의 문항';

-- =====================================================
-- Indexes for Performance
-- =====================================================

-- Text search indexes
CREATE INDEX idx_passages_content_gin ON passages USING gin(to_tsvector('korean', content));
CREATE INDEX idx_questions_prompt_gin ON questions USING gin(to_tsvector('korean', prompt));
CREATE INDEX idx_submissions_text_gin ON student_submissions USING gin(to_tsvector('korean', submission_text));

-- Vector similarity search index
CREATE INDEX idx_passages_embedding ON passages USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- Foreign key indexes
CREATE INDEX idx_exams_university ON exams(university_id);
CREATE INDEX idx_passages_exam ON passages(exam_id);
CREATE INDEX idx_questions_exam ON questions(exam_id);
CREATE INDEX idx_submissions_user ON student_submissions(user_id);
CREATE INDEX idx_submissions_question ON student_submissions(question_id);
CREATE INDEX idx_feedbacks_submission ON ai_feedbacks(submission_id);

-- Query optimization indexes
CREATE INDEX idx_submissions_date ON student_submissions(submission_date DESC);
CREATE INDEX idx_exams_year ON exams(year DESC);
CREATE INDEX idx_progress_user ON student_progress(user_id);

-- =====================================================
-- Row Level Security (RLS)
-- =====================================================

-- Enable RLS on sensitive tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_feedbacks ENABLE ROW LEVEL SECURITY;
ALTER TABLE feedback_ratings ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_progress ENABLE ROW LEVEL SECURITY;

-- Users can only see their own data
CREATE POLICY "Users can view own profile" ON users
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own submissions" ON student_submissions
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view own feedback" ON ai_feedbacks
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM student_submissions 
      WHERE submission_id = ai_feedbacks.submission_id 
      AND user_id = auth.uid()
    )
  );

CREATE POLICY "Users can rate own feedback" ON feedback_ratings
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view own progress" ON student_progress
  FOR SELECT USING (auth.uid() = user_id);

-- Public data is accessible to all
CREATE POLICY "Public can view universities" ON universities FOR SELECT USING (true);
CREATE POLICY "Public can view exams" ON exams FOR SELECT USING (true);
CREATE POLICY "Public can view passages" ON passages FOR SELECT USING (true);
CREATE POLICY "Public can view questions" ON questions FOR SELECT USING (true);
CREATE POLICY "Public can view official analyses" ON official_analyses FOR SELECT USING (true);
CREATE POLICY "Public can view feedback categories" ON feedback_categories FOR SELECT USING (true);
CREATE POLICY "Public can view learning resources" ON learning_resources FOR SELECT USING (true);

-- =====================================================
-- Functions and Triggers
-- =====================================================

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_universities_updated_at BEFORE UPDATE ON universities
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_learning_resources_updated_at BEFORE UPDATE ON learning_resources
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to calculate passage utilization
CREATE OR REPLACE FUNCTION calculate_passage_utilization(
  p_submission_text TEXT,
  p_question_id INTEGER
) RETURNS JSONB AS $$
DECLARE
  v_result JSONB := '{}';
  v_passage RECORD;
BEGIN
  FOR v_passage IN 
    SELECT p.label, p.keywords
    FROM passages p
    JOIN question_passage_link qpl ON p.passage_id = qpl.passage_id
    WHERE qpl.question_id = p_question_id
  LOOP
    -- Calculate keyword match percentage
    -- This is a simplified version; real implementation would be more sophisticated
    v_result := v_result || jsonb_build_object(
      v_passage.label, 
      LEAST(100, array_length(
        ARRAY(
          SELECT keyword FROM unnest(v_passage.keywords) AS keyword
          WHERE p_submission_text ILIKE '%' || keyword || '%'
        ), 1
      ) * 20)
    );
  END LOOP;
  
  RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Initial Data Insert for Testing
-- =====================================================

-- Insert sample universities with their essay types
INSERT INTO universities (name, name_en, university_type, emphasis_points) VALUES
('연세대학교', 'Yonsei University', '융합 심층형', '{"논리성": 30, "창의성": 25, "자료활용": 25, "표현력": 20}'),
('고려대학교', 'Korea University', '융합 심층형', '{"논리성": 35, "비판적사고": 25, "문제해결": 20, "표현력": 20}'),
('성균관대학교', 'Sungkyunkwan University', '정형화된 연계형', '{"자료해석": 30, "논증": 30, "구성": 20, "표현": 20}'),
('서강대학교', 'Sogang University', '통합 서술형', '{"통합능력": 35, "철학적사고": 30, "표현력": 20, "창의성": 15}'),
('경희대학교', 'Kyung Hee University', '복합 과제형', '{"평가능력": 30, "비판력": 30, "논리성": 25, "표현": 15}'),
('중앙대학교', 'Chung-Ang University', '복합 과제형', '{"적용능력": 30, "분석력": 30, "창의성": 20, "구성": 20}'),
('한국외국어대학교', 'HUFS', '정형화된 연계형', '{"분류능력": 25, "해석력": 25, "논증": 30, "표현": 20}'),
('서울시립대학교', 'University of Seoul', '통합 서술형', '{"논리성": 30, "창의성": 25, "자료활용": 25, "표현": 20}'),
('건국대학교', 'Konkuk University', '복합 과제형', '{"분석력": 30, "비판력": 25, "창의성": 25, "표현": 20}'),
('한양대학교', 'Hanyang University', '정형화된 연계형', '{"논증력": 30, "자료활용": 30, "구성": 20, "표현": 20}')
ON CONFLICT (name) DO UPDATE SET 
  university_type = EXCLUDED.university_type,
  emphasis_points = EXCLUDED.emphasis_points;

-- Insert sample feedback categories
INSERT INTO feedback_categories (category_code, category_name, description, severity_level, typical_deduction) VALUES
('LOGIC_ERROR', '논리 오류', '전제와 결론 사이의 논리적 연결이 부족함', 4, 10),
('EVIDENCE_LACK', '근거 부족', '주장을 뒷받침하는 구체적 근거가 부족함', 3, 7),
('OFF_TOPIC', '논제 이탈', '문제에서 요구한 내용과 다른 내용을 서술함', 5, 15),
('POOR_STRUCTURE', '구성 미흡', '글의 구조가 체계적이지 못함', 3, 5),
('EXPRESSION_ERROR', '표현 오류', '문법 오류나 부적절한 어휘 사용', 2, 3),
('PASSAGE_MISUSE', '제시문 오용', '제시문을 잘못 이해하거나 부적절하게 활용함', 4, 8),
('INCOMPLETE', '미완성', '요구된 분량이나 내용을 충족하지 못함', 4, 10)
ON CONFLICT (category_code) DO NOTHING;

-- =====================================================
-- Verification Query
-- =====================================================

DO $$
BEGIN
  RAISE NOTICE '=== Essay Database Schema Creation Complete ===';
  RAISE NOTICE 'Universities: %', (SELECT COUNT(*) FROM universities);
  RAISE NOTICE 'Feedback Categories: %', (SELECT COUNT(*) FROM feedback_categories);
  RAISE NOTICE 'Total Tables Created: 15';
  RAISE NOTICE '===============================================';
END $$;