# HYLE 데이터베이스 전체 구조 분석

## 📊 데이터베이스 개요
- **데이터베이스**: PostgreSQL (Supabase)
- **확장 기능**: uuid-ossp, pgvector (AI 임베딩)
- **총 테이블 수**: 약 80개 이상
- **주요 도메인**: 학습 관리, 소셜, 논술 AI, 관리자, 게이미피케이션

## 🗂️ 데이터베이스 구조 (도메인별)

### 1. 핵심 사용자 시스템 (Core User System)
```
┌─────────────────────────────────┐
│         users_profile           │ ← Supabase Auth 연동
├─────────────────────────────────┤
│ id (UUID) - PK                  │
│ email, name, learning_type      │
│ level, xp, streak_days          │
│ avatar_url, last_study_date     │
└─────────────────────────────────┘
          ↓ 1:N 관계
┌──────────────────┬──────────────────┬──────────────────┐
│ study_sessions   │      todos       │     streaks      │
│ - duration       │ - content        │ - start_date     │
│ - focus_score    │ - priority       │ - days           │
│ - subject        │ - due_date       │ - is_active      │
└──────────────────┴──────────────────┴──────────────────┘
```

### 2. 게이미피케이션 시스템 (Gamification)
```
users_profile
     ↓
┌──────────────────┬──────────────────┬──────────────────┐
│     quests       │   achievements   │    missions      │
│ - daily/weekly   │ - badges         │ - challenges     │
│ - xp_reward      │ - rarity         │ - guild_missions │
└──────────────────┴──────────────────┴──────────────────┘
```

### 3. 프리미엄/AI 기능 (Premium Features)
```
premium_subscriptions
     ↓ (활성화 시)
┌──────────────────┬──────────────────┬──────────────────┐
│ ai_conversations │ knowledge_nodes  │  user_patterns   │
│ - thread_id      │ - concept        │ - pattern_type   │
│ - embedding      │ - mastery_level  │ - confidence     │
│ - sentiment      │ - connections    │ - pattern_data   │
└──────────────────┴──────────────────┴──────────────────┘
                   ↓
            learning_insights
            - insight_type
            - confidence_score
```

### 4. 소셜 기능 (Social Features) - 005_social_features.sql
```
users_profile
     ↓
┌──────────────────┬──────────────────┬──────────────────┐
│user_relationships│  friend_requests │   guilds         │
│ - follower_id    │ - sender_id      │ - name           │
│ - following_id   │ - receiver_id    │ - max_members    │
│ - is_mutual      │ - status         │ - category       │
└──────────────────┴──────────────────┴──────────────────┘
                          ↓
                    guild_members
                    - role (owner/admin/member)
                    - contribution_xp
                          ↓
┌──────────────────┬──────────────────┬──────────────────┐
│  chat_rooms      │    messages      │  leaderboards    │
│ - type           │ - content        │ - global_rank    │
│ - guild_id       │ - attachments    │ - weekly_xp      │
└──────────────────┴──────────────────┴──────────────────┘

플래시카드 시스템:
flashcard_decks → flashcards → user_flashcard_progress
                                (Spaced Repetition)

릴스(짧은 교육 영상):
study_reels → user_reel_interactions
- video_url    - watch_time
- embedding    - quiz_score
```

### 5. 인문논술 AI 시스템 (Essay AI) - 006~010 migrations
```
대학 정보:
universities (10개 대학)
     ↓
┌──────────────────┬──────────────────┬──────────────────┐
│     exams        │   essay_topics   │    passages      │
│ - year           │ - question_text  │ - content        │
│ - session        │ - word_limit     │ - embedding      │
│ - time_limit     │ - difficulty     │ - is_english     │
└──────────────────┴──────────────────┴──────────────────┘

온톨로지 & NAG:
┌──────────────────┬──────────────────┬──────────────────┐
│essay_ontology_   │   nag_nodes      │   nag_edges      │
│    themes        │ - node_type      │ - from_node      │
│ - theme_category │ - content        │ - to_node        │
│ - frequency      │ - embedding      │ - edge_type      │
└──────────────────┴──────────────────┴──────────────────┘

채점 시스템:
┌──────────────────┬──────────────────┬──────────────────┐
│essay_submissions │submission_spans  │ span_alignment   │
│ - essay_text     │ - span_type      │ - nli_score      │
│ - word_count     │ - discourse_role │ - embedding_sim  │
└──────────────────┴──────────────────┴──────────────────┘
                          ↓
┌──────────────────┬──────────────────┬──────────────────┐
│essay_ai_analysis │ expert_reviews   │grading_quality_  │
│ - total_score    │ - score          │    metrics       │
│ - rubric_scores  │ - feedback       │ - qwk_score      │
│ - strengths      │ - recommendations│ - bias_indicators│
└──────────────────┴──────────────────┴──────────────────┘

루브릭 & GraphRAG:
┌──────────────────┬──────────────────┬──────────────────┐
│    rubrics       │ rubric_criteria  │ graphrag_index   │
│ - thesis_weight  │ - criterion_type │ - embedding      │
│ - evidence_weight│ - level (1-5)    │ - item_type      │
└──────────────────┴──────────────────┴──────────────────┘

학습 지원:
┌──────────────────┬──────────────────┬──────────────────┐
│ coaching_missions│ error_catalog    │learning_analytics│
│ - target_skill   │ - error_type     │ - writing_patterns│
│ - xp_reward      │ - improvement    │ - predicted_score│
└──────────────────┴──────────────────┴──────────────────┘
```

### 6. 관리자 시스템 (Admin System)
```
admin_users (별도 인증)
     ↓
┌──────────────────┬──────────────────┬──────────────────┐
│   audit_logs     │dashboard_widgets │ admin_sessions   │
│ - action         │ - widget_type    │ - token_hash     │
│ - target_type    │ - position       │ - expires_at     │
└──────────────────┴──────────────────┴──────────────────┘

시스템 관리:
┌──────────────────┬──────────────────┬──────────────────┐
│system_settings   │ feature_flags    │ announcements    │
│ - key/value      │ - is_enabled     │ - type           │
│                  │ - rollout_%      │ - target_audience│
└──────────────────┴──────────────────┴──────────────────┘

콘텐츠 & 지원:
┌──────────────────┬──────────────────┬──────────────────┐
│content_templates │support_tickets   │ai_prompt_templates│
│ - type (quest)   │ - category       │ - prompt_text    │
│ - xp_reward      │ - priority       │ - model          │
└──────────────────┴──────────────────┴──────────────────┘

모니터링:
api_usage
- service (openai, supabase)
- tokens_used
- cost_usd
```

### 7. 통합 스키마 (010_essay_comprehensive_schema.sql)
```
완전히 새로운 15개 테이블 구조:
1. universities - 대학 정보
2. exams - 시험 세션
3. passages - 제시문
4. questions - 문항
5. question_passage_link - 문항-제시문 연결
6. official_analyses - Ground Truth (AI 학습 핵심)
7. users - 학생 정보
8. student_submissions - 답안
9. ai_feedbacks - AI 첨삭
10. feedback_ratings - RLHF용 평가
11. feedback_categories - 표준 피드백 유형
12. learning_resources - 학습 자료
13. question_themes - 출제경향
14. student_progress - 진행도
15. mock_questions - AI 생성 모의문항
```

## 🔗 주요 관계 (Relationships)

### 1:N 관계
- users_profile → study_sessions, todos, streaks, quests
- universities → exams → questions → passages
- essay_submissions → essay_ai_analysis, expert_reviews
- guilds → guild_members, guild_missions
- flashcard_decks → flashcards → user_flashcard_progress

### N:N 관계 (Junction Tables)
- users ↔ guilds (via guild_members)
- questions ↔ passages (via question_passage_link)
- users ↔ users (via user_relationships)

### 계층 구조
- essay_ontology_themes → parent_theme (자기 참조)
- messages → reply_to_id (자기 참조)
- nag_nodes → nag_edges (그래프 구조)

## 🔐 보안 (Row Level Security)

### 기본 원칙
- 모든 테이블에 RLS 활성화
- 사용자는 자신의 데이터만 접근
- 프리미엄 기능은 구독 상태 확인

### 정책 예시
```sql
-- 일반 사용자
CREATE POLICY "Users can manage own data" 
ON table_name FOR ALL 
USING (auth.uid() = user_id);

-- 프리미엄 사용자
CREATE POLICY "Premium users only" 
ON premium_table FOR ALL 
USING (
  EXISTS (
    SELECT 1 FROM premium_subscriptions 
    WHERE user_id = auth.uid() 
    AND is_active = true
  )
);

-- 관리자
CREATE POLICY "Admin access" 
ON admin_table FOR ALL 
USING (
  EXISTS (
    SELECT 1 FROM admin_users 
    WHERE id = auth.uid() 
    AND role IN ('super_admin', 'admin')
  )
);
```

## 🚀 성능 최적화

### 인덱스 전략
```sql
-- 빈번한 조회
CREATE INDEX ON table(user_id);
CREATE INDEX ON table(created_at DESC);

-- 복합 인덱스
CREATE INDEX ON ai_conversations(user_id, thread_id);

-- 벡터 검색 (pgvector)
CREATE INDEX ON passages USING ivfflat (embedding vector_cosine_ops);

-- 한국어 전문 검색
CREATE INDEX ON questions USING gin(to_tsvector('korean', prompt));
```

### 트리거
- updated_at 자동 업데이트
- 캐스케이드 삭제 설정
- 데이터 일관성 보장

## 🎯 개선 제안

### 1. 구조적 개선
- [ ] 테이블 통합: essay 관련 테이블이 3개 파일에 분산
- [ ] 네이밍 일관성: snake_case vs camelCase 혼재
- [ ] 중복 제거: users vs users_profile 통합 필요

### 2. 성능 개선
- [ ] 파티셔닝: 대용량 테이블 (submissions, messages)
- [ ] 매터리얼라이즈드 뷰: 통계/분석 데이터
- [ ] 캐싱 전략: Redis 도입 고려

### 3. 기능 추가
- [ ] 버전 관리: 답안/문서 버전 추적
- [ ] 실시간 기능: Supabase Realtime 활용
- [ ] 백업/복구: 정기 백업 정책

### 4. 보안 강화
- [ ] 암호화: 민감 데이터 암호화
- [ ] 감사 로그: 모든 데이터 변경 추적
- [ ] 접근 제어: 더 세밀한 RLS 정책

## 📈 통계
- **총 테이블**: ~80개
- **pgvector 사용**: 6개 테이블
- **JSONB 필드**: 30개 이상
- **RLS 정책**: 50개 이상
- **인덱스**: 40개 이상
- **트리거**: 10개 이상