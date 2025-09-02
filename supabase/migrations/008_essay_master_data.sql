-- =====================================================
-- Essay AI Master Data Insertion
-- 인문논술 AI 마스터 데이터 삽입
-- =====================================================

-- =====================================================
-- 1. UNIVERSITIES (대학 정보)
-- =====================================================

-- 실제 준비 중인 10개 대학
-- 주의: 아래 평가 기준은 예시이며, 실제 각 대학의 공식 평가 기준을 확인하여 업데이트 필요
INSERT INTO universities (name, name_en, essay_type, typical_topics, difficulty_level, evaluation_criteria, scoring_rubric) VALUES
('연세대학교', 'Yonsei University', '인문논술', 
  NULL, -- 실제 기출 분석 후 입력 필요
  NULL, -- 난이도는 실제 데이터 수집 후 설정
  NULL, -- 실제 평가 기준 확인 필요
  NULL), -- 실제 채점 기준표 확인 필요

('고려대학교', 'Korea University', '인문논술',
  NULL,
  NULL,
  NULL,
  NULL),

('성균관대학교', 'Sungkyunkwan University', '인문논술',
  NULL,
  NULL,
  NULL,
  NULL),

('한양대학교', 'Hanyang University', '인문논술',
  NULL,
  NULL,
  NULL,
  NULL),

('서강대학교', 'Sogang University', '인문논술',
  NULL,
  NULL,
  NULL,
  NULL),

('중앙대학교', 'Chung-Ang University', '인문논술',
  NULL,
  NULL,
  NULL,
  NULL),

('경희대학교', 'Kyung Hee University', '인문논술',
  NULL,
  NULL,
  NULL,
  NULL),

('한국외국어대학교', 'Hankuk University of Foreign Studies', '인문논술',
  NULL,
  NULL,
  NULL,
  NULL),

('서울시립대학교', 'University of Seoul', '인문논술',
  NULL,
  NULL,
  NULL,
  NULL),

('건국대학교', 'Konkuk University', '인문논술',
  NULL,
  NULL,
  NULL,
  NULL);

-- =====================================================
-- 2. PLACEHOLDER DATA (실제 데이터 수집 전 임시)
-- =====================================================

-- 아래는 시스템 테스트를 위한 최소한의 더미 데이터입니다.
-- 실제 서비스 운영 전에 각 대학의 기출문제 분석을 통해
-- 정확한 데이터로 교체해야 합니다.

-- 과제 유형 (일반적인 논술 유형 - 실제 기출 분석 후 수정 필요)
INSERT INTO essay_task_types (task_type, description) VALUES
('요약형', '제시문의 핵심 내용을 정리하는 문제'),
('비교형', '제시문들을 비교 분석하는 문제'),
('비판형', '특정 입장을 비판적으로 검토하는 문제'),
('설명형', '개념이나 현상을 설명하는 문제'),
('논증형', '자신의 견해를 논리적으로 전개하는 문제');

-- =====================================================
-- 3. ESSAY ONTOLOGY THEMES (출제경향 주제)
-- =====================================================

INSERT INTO essay_ontology_themes (theme_category, theme_name, theme_keywords, frequency_score) VALUES
('사회', '개인과 공동체', ARRAY['개인주의', '공동체주의', '사회계약', '시민성'], 0.85),
('윤리', '정의와 평등', ARRAY['분배정의', '기회균등', '공정성', '형평성'], 0.80),
('문화', '전통과 현대', ARRAY['문화계승', '현대화', '정체성', '글로벌화'], 0.75),
('경제', '자본주의와 복지', ARRAY['시장경제', '복지국가', '불평등', '재분배'], 0.70),
('정치', '민주주의와 권력', ARRAY['민주주의', '권력분립', '시민참여', '거버넌스'], 0.65),
('철학', '자유와 책임', ARRAY['자유의지', '도덕적책임', '결정론', '실존주의'], 0.60),
('과학', '기술과 인간', ARRAY['AI윤리', '생명공학', '디지털전환', '인간성'], 0.75),
('환경', '지속가능성', ARRAY['기후변화', '생태계', '미래세대', '환경정의'], 0.70);

-- =====================================================
-- 4. ERROR CATALOG (오류 카탈로그)
-- =====================================================

INSERT INTO error_catalog (error_type, error_category, description, typical_causes, improvement_strategies) VALUES
('논제이탈', 'logic', '주어진 논제에서 벗어난 논의 전개',
  ARRAY['논제 오독', '과도한 확대해석', '개인 의견 과다'],
  ARRAY['논제 키워드 정확히 파악', '문제 요구사항 재확인', '제시문 범위 내 논의']),

('근거부족', 'evidence', '주장에 대한 구체적 근거 제시 미흡',
  ARRAY['제시문 활용 부족', '추상적 서술', '예시 부재'],
  ARRAY['제시문에서 근거 찾기', '구체적 사례 제시', '인용과 해석 균형']),

('논리비약', 'logic', '전제와 결론 사이의 논리적 연결 부족',
  ARRAY['중간 단계 생략', '인과관계 오류', '성급한 일반화'],
  ARRAY['단계별 논증 구성', '전제 명확히 제시', '반례 고려']),

('구성산만', 'structure', '글의 구조가 체계적이지 못함',
  ARRAY['서론-본론-결론 미구분', '문단 간 연결 부족', '중복 서술'],
  ARRAY['개요 작성 후 작성', '문단별 핵심 문장', '연결어 활용']),

('표현미숙', 'expression', '문장 표현이 어색하거나 부적절함',
  ARRAY['구어체 사용', '문법 오류', '어휘 선택 부적절'],
  ARRAY['문어체 연습', '문법 검토', '학술 어휘 학습']);

-- =====================================================
-- 5. RUBRICS TEMPLATE (루브릭 템플릿)
-- =====================================================

-- 표준 루브릭 생성 (대학별로 커스터마이징 가능)
WITH standard_rubric AS (
  INSERT INTO rubrics (name, version, thesis_weight, evidence_weight, source_use_weight, organization_weight, style_weight, compliance_weight)
  VALUES ('표준 인문논술 루브릭', 'v1.0', 0.20, 0.25, 0.20, 0.15, 0.10, 0.10)
  RETURNING id
)
INSERT INTO rubric_criteria (rubric_id, criterion_type, level, description, score_range_min, score_range_max) 
SELECT 
  id,
  criterion,
  level,
  description,
  score_min,
  score_max
FROM standard_rubric,
LATERAL (VALUES
  -- 논제 이해 (thesis)
  ('thesis', 5, '논제를 완벽히 이해하고 창의적으로 해석', 18, 20),
  ('thesis', 4, '논제를 정확히 이해하고 적절히 해석', 14, 17),
  ('thesis', 3, '논제를 대체로 이해하나 일부 오해', 10, 13),
  ('thesis', 2, '논제 이해가 부족하고 해석이 미흡', 6, 9),
  ('thesis', 1, '논제를 잘못 이해하거나 이탈', 0, 5),
  
  -- 근거 활용 (evidence)
  ('evidence', 5, '제시문을 완벽히 활용하고 창의적으로 연결', 23, 25),
  ('evidence', 4, '제시문을 적절히 활용하고 논리적으로 연결', 18, 22),
  ('evidence', 3, '제시문을 부분적으로 활용', 13, 17),
  ('evidence', 2, '제시문 활용이 미흡하거나 부적절', 8, 12),
  ('evidence', 1, '제시문을 거의 활용하지 않음', 0, 7),
  
  -- 자료 활용 (source_use)
  ('source_use', 5, '모든 제시문을 균형있게 활용', 18, 20),
  ('source_use', 4, '대부분의 제시문을 적절히 활용', 14, 17),
  ('source_use', 3, '일부 제시문만 활용', 10, 13),
  ('source_use', 2, '제시문 활용이 편향되거나 부족', 6, 9),
  ('source_use', 1, '제시문을 거의 활용하지 않음', 0, 5),
  
  -- 구성 (organization)
  ('organization', 5, '완벽한 구조와 논리적 흐름', 14, 15),
  ('organization', 4, '체계적 구조와 적절한 흐름', 11, 13),
  ('organization', 3, '기본적 구조는 있으나 일부 산만', 8, 10),
  ('organization', 2, '구조가 불명확하고 흐름이 어색', 5, 7),
  ('organization', 1, '구조가 없고 매우 산만', 0, 4),
  
  -- 문체 (style)
  ('style', 5, '명료하고 설득력 있는 문체', 9, 10),
  ('style', 4, '적절하고 읽기 쉬운 문체', 7, 8),
  ('style', 3, '대체로 적절하나 일부 어색', 5, 6),
  ('style', 2, '문체가 미숙하고 어색함', 3, 4),
  ('style', 1, '문체가 매우 부적절', 0, 2),
  
  -- 형식 준수 (compliance)
  ('compliance', 5, '모든 형식 요건 완벽 준수', 9, 10),
  ('compliance', 4, '대부분의 형식 요건 준수', 7, 8),
  ('compliance', 3, '기본 형식은 준수', 5, 6),
  ('compliance', 2, '형식 준수 미흡', 3, 4),
  ('compliance', 1, '형식 요건 위반', 0, 2)
) AS t(criterion, level, description, score_min, score_max);

-- =====================================================
-- 6. COACHING MISSIONS TEMPLATES (코칭 미션 템플릿)
-- =====================================================

INSERT INTO coaching_missions (user_id, mission_type, title, description, target_skill, difficulty_level, xp_reward)
SELECT 
  '00000000-0000-0000-0000-000000000000'::UUID, -- 템플릿용 더미 ID
  mission_type,
  title,
  description,
  target_skill,
  difficulty,
  xp
FROM (VALUES
  ('practice', '제시문 요약 연습', '주어진 제시문을 200자 이내로 요약하기', '자료 활용', 1, 50),
  ('practice', '논증 구조 분석', '예시 답안의 논증 구조를 도식화하기', '논리성', 2, 100),
  ('revision', '근거 보강하기', '이전 답안에 제시문 근거 3개 추가하기', '근거 활용', 2, 150),
  ('revision', '반론 추가하기', '기존 주장에 대한 반론과 재반박 추가', '비판적 사고', 3, 200),
  ('study', '오답 노트 작성', '틀린 부분을 분석하고 개선안 작성', '메타인지', 2, 100),
  ('study', '우수 답안 분석', '만점 답안과 자신의 답안 비교 분석', '학습 전략', 3, 150)
) AS t(mission_type, title, description, target_skill, difficulty, xp);

-- =====================================================
-- 7. ACHIEVEMENT DEFINITIONS (업적 정의)
-- =====================================================

INSERT INTO achievements (name, description, category, requirements, xp_reward, rarity) VALUES
('첫 걸음', '첫 논술 답안 제출', '신규', '{"submissions": 1}'::JSONB, 100, 'common'),
('꾸준한 연습', '7일 연속 답안 제출', '지속', '{"streak_days": 7}'::JSONB, 500, 'rare'),
('논술 마스터', '평균 점수 85점 이상 달성', '실력', '{"avg_score": 85}'::JSONB, 1000, 'epic'),
('개선의 아이콘', '리비전으로 20점 이상 향상', '성장', '{"improvement": 20}'::JSONB, 750, 'rare'),
('제시문 정복자', '자료 활용 만점 5회 달성', '전문', '{"perfect_evidence": 5}'::JSONB, 800, 'epic'),
('대학별 전문가', '특정 대학 문제 20개 이상 풀이', '전문', '{"university_count": 20}'::JSONB, 600, 'rare'),
('피드백 실천가', '코칭 미션 10개 완료', '학습', '{"missions_completed": 10}'::JSONB, 400, 'common');

-- =====================================================
-- 8. SAMPLE NAG NODE TYPES (NAG 노드 유형 예시)
-- =====================================================

-- 이것은 실제 문제별로 생성되어야 하지만, 템플릿으로 제공
INSERT INTO nag_nodes (topic_id, node_type, content, importance_weight, source_passage) 
SELECT
  NULL, -- 실제 문제 생성 시 연결
  node_type,
  content,
  weight,
  source
FROM (VALUES
  ('claim', '개인의 자유와 공동체의 이익은 균형을 이루어야 한다', 1.0, 1),
  ('evidence', '제시문 가에서 롤스는 자유의 우선성을 강조한다', 0.8, 1),
  ('evidence', '제시문 나는 공동체주의 관점을 제시한다', 0.8, 2),
  ('counter', '극단적 개인주의는 사회 붕괴를 초래할 수 있다', 0.6, NULL),
  ('assumption', '인간은 사회적 존재라는 전제', 0.4, NULL),
  ('example', '북유럽 복지국가 모델이 균형의 예시', 0.5, 3)
) AS t(node_type, content, weight, source);

-- =====================================================
-- 9. INDEX FOR PERFORMANCE
-- =====================================================

-- Create additional indexes for frequently queried columns
CREATE INDEX IF NOT EXISTS idx_universities_name ON universities(name);
CREATE INDEX IF NOT EXISTS idx_essay_topics_category ON essay_topics(topic_category);
CREATE INDEX IF NOT EXISTS idx_essay_submissions_created ON essay_submissions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_essay_ai_analysis_grade ON essay_ai_analysis(grade);

-- =====================================================
-- 10. VERIFICATION QUERIES
-- =====================================================

-- 데이터 삽입 확인용 쿼리들
DO $$
BEGIN
  RAISE NOTICE '=== Master Data Insertion Summary ===';
  RAISE NOTICE 'Universities inserted: %', (SELECT COUNT(*) FROM universities);
  RAISE NOTICE 'Task types inserted: %', (SELECT COUNT(*) FROM essay_task_types);
  RAISE NOTICE 'Themes inserted: %', (SELECT COUNT(*) FROM essay_ontology_themes);
  RAISE NOTICE 'Error types inserted: %', (SELECT COUNT(*) FROM error_catalog);
  RAISE NOTICE 'Rubric criteria inserted: %', (SELECT COUNT(*) FROM rubric_criteria);
  RAISE NOTICE 'Achievements defined: %', (SELECT COUNT(*) FROM achievements);
  RAISE NOTICE '=====================================';
END $$;