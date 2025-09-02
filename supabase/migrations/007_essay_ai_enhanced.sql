-- =====================================================
-- HYLE Essay AI Enhanced Schema
-- 온톨로지 & GraphRAG 기반 인문논술 채점 시스템
-- =====================================================

-- =====================================================
-- ONTOLOGY SYSTEM (온톨로지 시스템)
-- =====================================================

-- Essay Ontology Themes (출제경향 온톨로지)
CREATE TABLE IF NOT EXISTS essay_ontology_themes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  university_id UUID REFERENCES universities(id),
  
  -- 주제 분류
  theme_category VARCHAR(100), -- 사회, 윤리, 문화, 경제, 정치, 철학
  theme_name VARCHAR(255) NOT NULL,
  theme_keywords TEXT[], -- 핵심 키워드
  
  -- 출제 빈도
  frequency_score FLOAT, -- 0-1 출제 빈도
  last_appeared_year INTEGER,
  appearance_count INTEGER DEFAULT 0,
  
  -- 연관 관계
  related_themes UUID[], -- 연관 주제들
  parent_theme UUID REFERENCES essay_ontology_themes(id),
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Task Types Ontology (과제 유형 온톨로지)
CREATE TABLE IF NOT EXISTS essay_task_types (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  task_type VARCHAR(100) NOT NULL, -- 비교분석, 논증, 비판, 종합 등
  description TEXT,
  
  -- 평가 기준
  evaluation_focus TEXT[], -- 주요 평가 포인트
  typical_structure TEXT, -- 전형적인 답안 구조
  
  -- 난이도
  cognitive_level INTEGER CHECK (cognitive_level BETWEEN 1 AND 6), -- Bloom's Taxonomy
  difficulty_weight FLOAT DEFAULT 1.0,
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- NAG SYSTEM (정답 그래프 시스템)
-- =====================================================

-- NAG Nodes (정답 그래프 노드)
CREATE TABLE IF NOT EXISTS nag_nodes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  topic_id UUID REFERENCES essay_topics(id) ON DELETE CASCADE,
  
  -- 노드 정보
  node_type VARCHAR(50), -- claim, evidence, counter, assumption, constraint, example
  content TEXT NOT NULL,
  importance_weight FLOAT DEFAULT 1.0, -- 0-1 중요도 가중치
  
  -- 제시문 연결
  source_passage INTEGER, -- 제시문 번호
  source_excerpt TEXT, -- 관련 제시문 발췌
  
  -- 임베딩
  embedding vector(1536), -- OpenAI text-embedding-3-large
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- NAG Edges (정답 그래프 엣지)
CREATE TABLE IF NOT EXISTS nag_edges (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  from_node UUID REFERENCES nag_nodes(id) ON DELETE CASCADE,
  to_node UUID REFERENCES nag_nodes(id) ON DELETE CASCADE,
  
  -- 관계 정보
  edge_type VARCHAR(50), -- supports, contradicts, requires, exemplifies
  strength FLOAT DEFAULT 1.0, -- 관계 강도
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(from_node, to_node, edge_type)
);

-- =====================================================
-- RUBRIC SYSTEM (루브릭 시스템)
-- =====================================================

-- Rubrics (채점 기준표)
CREATE TABLE IF NOT EXISTS rubrics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  university_id UUID REFERENCES universities(id),
  topic_id UUID REFERENCES essay_topics(id),
  
  -- 루브릭 정보
  name VARCHAR(255) NOT NULL,
  version VARCHAR(20),
  
  -- 가중치
  thesis_weight FLOAT DEFAULT 0.2, -- 논제 이해
  evidence_weight FLOAT DEFAULT 0.25, -- 근거 활용
  source_use_weight FLOAT DEFAULT 0.2, -- 제시문 활용
  organization_weight FLOAT DEFAULT 0.15, -- 구성
  style_weight FLOAT DEFAULT 0.1, -- 문체
  compliance_weight FLOAT DEFAULT 0.1, -- 형식 준수
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Rubric Criteria (루브릭 세부 기준)
CREATE TABLE IF NOT EXISTS rubric_criteria (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  rubric_id UUID REFERENCES rubrics(id) ON DELETE CASCADE,
  
  -- 기준 정보
  criterion_type VARCHAR(50), -- thesis, evidence, source_use, organization, style, compliance
  level INTEGER CHECK (level BETWEEN 1 AND 5), -- 1: 매우 미흡, 5: 우수
  
  -- 평가 내용
  description TEXT NOT NULL,
  score_range_min FLOAT,
  score_range_max FLOAT,
  
  -- 예시
  examples TEXT[],
  common_mistakes TEXT[],
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- GRADING PIPELINE (채점 파이프라인)
-- =====================================================

-- Submission Spans (답안 스팬 분석)
CREATE TABLE IF NOT EXISTS submission_spans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  submission_id UUID REFERENCES essay_submissions(id) ON DELETE CASCADE,
  
  -- 스팬 정보
  span_type VARCHAR(50), -- sentence, paragraph, section
  span_order INTEGER NOT NULL,
  content TEXT NOT NULL,
  
  -- 담화 역할
  discourse_role VARCHAR(50), -- intro, thesis, evidence, counter, conclusion
  
  -- 임베딩
  embedding vector(1536),
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Span Alignment (스팬-NAG 정렬)
CREATE TABLE IF NOT EXISTS span_alignment (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  span_id UUID REFERENCES submission_spans(id) ON DELETE CASCADE,
  nag_node_id UUID REFERENCES nag_nodes(id),
  
  -- 정렬 점수
  nli_score FLOAT, -- Natural Language Inference score
  embedding_similarity FLOAT, -- 코사인 유사도
  combined_score FLOAT, -- 종합 점수
  
  -- 정렬 상태
  alignment_type VARCHAR(50), -- entailment, contradiction, neutral
  confidence FLOAT,
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- GRAPHRAG SYSTEM (그래프RAG 시스템)
-- =====================================================

-- GraphRAG Index (벡터 인덱스)
CREATE TABLE IF NOT EXISTS graphrag_index (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- 인덱스 항목
  item_type VARCHAR(50), -- rubric, nag_node, exemplar, error_pattern
  item_id UUID, -- 참조하는 항목의 ID
  
  -- 내용
  content TEXT NOT NULL,
  metadata JSONB,
  
  -- 임베딩
  embedding vector(1536),
  
  -- 검색 최적화
  keywords TEXT[],
  importance_score FLOAT DEFAULT 0.5,
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create vector similarity search index
CREATE INDEX IF NOT EXISTS idx_graphrag_embedding ON graphrag_index 
USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);

-- =====================================================
-- COACHING & FEEDBACK (코칭 및 피드백)
-- =====================================================

-- Error Catalog (오류 카탈로그)
CREATE TABLE IF NOT EXISTS error_catalog (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- 오류 정보
  error_type VARCHAR(100) NOT NULL,
  error_category VARCHAR(50), -- logic, evidence, structure, expression
  
  -- 설명
  description TEXT,
  typical_causes TEXT[],
  
  -- 개선 방법
  improvement_strategies TEXT[],
  example_corrections JSONB, -- {before: "...", after: "..."}
  
  -- 빈도
  occurrence_frequency INTEGER DEFAULT 0,
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Coaching Missions (코칭 미션)
CREATE TABLE IF NOT EXISTS coaching_missions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  submission_id UUID REFERENCES essay_submissions(id),
  
  -- 미션 정보
  mission_type VARCHAR(50), -- practice, revision, study
  title VARCHAR(255) NOT NULL,
  description TEXT,
  
  -- 목표
  target_skill VARCHAR(100), -- 개선할 영역
  difficulty_level INTEGER CHECK (difficulty_level BETWEEN 1 AND 5),
  
  -- 진행 상태
  status VARCHAR(50) DEFAULT 'assigned', -- assigned, in_progress, completed
  progress INTEGER DEFAULT 0,
  
  -- 보상
  xp_reward INTEGER DEFAULT 0,
  badge_reward VARCHAR(100),
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

-- =====================================================
-- MOCK EXAM GENERATION (모의문항 생성)
-- =====================================================

-- Mock Exam Templates (모의시험 템플릿)
CREATE TABLE IF NOT EXISTS mock_exam_templates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  university_id UUID REFERENCES universities(id),
  
  -- 템플릿 정보
  template_name VARCHAR(255) NOT NULL,
  template_type VARCHAR(50), -- 기출변형, AI생성, 전문가제작
  
  -- 구성 요소
  passage_structure JSONB, -- 제시문 구성 패턴
  question_patterns TEXT[], -- 질문 패턴
  
  -- 난이도 조절
  difficulty_parameters JSONB,
  
  -- 상태
  is_approved BOOLEAN DEFAULT FALSE,
  usage_count INTEGER DEFAULT 0,
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Generated Mock Exams (생성된 모의시험)
CREATE TABLE IF NOT EXISTS generated_mock_exams (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  template_id UUID REFERENCES mock_exam_templates(id),
  
  -- 생성 정보
  generation_method VARCHAR(50), -- llm, template, hybrid
  generation_params JSONB,
  
  -- 내용
  title VARCHAR(255),
  passages TEXT[], -- 제시문들
  questions TEXT[], -- 문제들
  
  -- 검증
  quality_score FLOAT,
  expert_reviewed BOOLEAN DEFAULT FALSE,
  reviewer_notes TEXT,
  
  -- 배포
  is_published BOOLEAN DEFAULT FALSE,
  published_at TIMESTAMPTZ,
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- QUALITY & MONITORING (품질 및 모니터링)
-- =====================================================

-- Grading Quality Metrics (채점 품질 지표)
CREATE TABLE IF NOT EXISTS grading_quality_metrics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  submission_id UUID REFERENCES essay_submissions(id),
  
  -- QWK (Quadratic Weighted Kappa)
  qwk_score FLOAT, -- 채점자 간 일치도
  
  -- 합의 채점
  consensus_rounds INTEGER DEFAULT 3,
  score_variance FLOAT,
  final_consensus_score FLOAT,
  
  -- 편향 검사
  bias_indicators JSONB, -- {gender_bias: 0.1, topic_bias: 0.2}
  
  -- 품질 보증
  quality_status VARCHAR(50), -- passed, review_needed, failed
  review_notes TEXT,
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Learning Analytics (학습 분석)
CREATE TABLE IF NOT EXISTS learning_analytics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  -- 학습 패턴
  writing_patterns JSONB, -- 글쓰기 패턴 분석
  common_errors JSONB, -- 자주 하는 실수
  improvement_trajectory JSONB, -- 향상 궤적
  
  -- 예측 모델
  predicted_score_next FLOAT, -- 다음 시험 예상 점수
  confidence_interval FLOAT,
  
  -- 추천
  recommended_focus_areas TEXT[],
  personalized_study_plan JSONB,
  
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- INDEXES FOR ENHANCED PERFORMANCE
-- =====================================================

-- Ontology indexes
CREATE INDEX idx_ontology_themes_university ON essay_ontology_themes(university_id);
CREATE INDEX idx_ontology_themes_category ON essay_ontology_themes(theme_category);

-- NAG indexes
CREATE INDEX idx_nag_nodes_topic ON nag_nodes(topic_id);
CREATE INDEX idx_nag_nodes_type ON nag_nodes(node_type);
CREATE INDEX idx_nag_nodes_embedding ON nag_nodes USING ivfflat (embedding vector_cosine_ops);

-- Span indexes
CREATE INDEX idx_submission_spans_submission ON submission_spans(submission_id);
CREATE INDEX idx_submission_spans_embedding ON submission_spans USING ivfflat (embedding vector_cosine_ops);

-- Alignment indexes
CREATE INDEX idx_span_alignment_span ON span_alignment(span_id);
CREATE INDEX idx_span_alignment_node ON span_alignment(nag_node_id);

-- Quality indexes
CREATE INDEX idx_quality_metrics_submission ON grading_quality_metrics(submission_id);
CREATE INDEX idx_quality_metrics_status ON grading_quality_metrics(quality_status);

-- =====================================================
-- ROW LEVEL SECURITY (RLS) FOR NEW TABLES
-- =====================================================

-- Enable RLS on all new tables
ALTER TABLE essay_ontology_themes ENABLE ROW LEVEL SECURITY;
ALTER TABLE essay_task_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE nag_nodes ENABLE ROW LEVEL SECURITY;
ALTER TABLE nag_edges ENABLE ROW LEVEL SECURITY;
ALTER TABLE rubrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE rubric_criteria ENABLE ROW LEVEL SECURITY;
ALTER TABLE submission_spans ENABLE ROW LEVEL SECURITY;
ALTER TABLE span_alignment ENABLE ROW LEVEL SECURITY;
ALTER TABLE graphrag_index ENABLE ROW LEVEL SECURITY;
ALTER TABLE error_catalog ENABLE ROW LEVEL SECURITY;
ALTER TABLE coaching_missions ENABLE ROW LEVEL SECURITY;
ALTER TABLE mock_exam_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE generated_mock_exams ENABLE ROW LEVEL SECURITY;
ALTER TABLE grading_quality_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE learning_analytics ENABLE ROW LEVEL SECURITY;

-- Public read policies for reference data
CREATE POLICY "Public can view ontology themes" ON essay_ontology_themes FOR SELECT USING (true);
CREATE POLICY "Public can view task types" ON essay_task_types FOR SELECT USING (true);
CREATE POLICY "Public can view error catalog" ON error_catalog FOR SELECT USING (true);

-- User-specific policies
CREATE POLICY "Users can view own coaching missions" ON coaching_missions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can view own analytics" ON learning_analytics
  FOR ALL USING (auth.uid() = user_id);

-- Protected policies for grading data
CREATE POLICY "Users can view own submission spans" ON submission_spans
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM essay_submissions 
      WHERE id = submission_spans.submission_id 
      AND user_id = auth.uid()
    )
  );

CREATE POLICY "Users can view own grading metrics" ON grading_quality_metrics
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM essay_submissions 
      WHERE id = grading_quality_metrics.submission_id 
      AND user_id = auth.uid()
    )
  );