# Claude Code Plan Mode Guide for Hyle Project

## 🎯 프로젝트 컨텍스트

Hyle은 AI 기반 학습 동반자 플랫폼으로, 학습을 게임처럼 재미있고 개인 과외처럼 맞춤형으로 만드는 것이 목표입니다.

## 📋 Plan Mode 프롬프트 템플릿

### 1. 새 기능 구현 시작할 때

```
I need to implement [기능명] for the Hyle learning companion app.

Current context:
- Flutter app with Riverpod state management
- Quest-based todo system with integrated timer
- Gamification with XP and levels
- Design system already implemented

Requirements for [기능명]:
1. [구체적인 요구사항 1]
2. [구체적인 요구사항 2]
3. [구체적인 요구사항 3]

Integration points:
- Should work with existing [연관 기능]
- Must follow the established design system
- Should update user XP/stats when [조건]

Please create a detailed implementation plan considering:
- File structure and organization
- State management approach
- UI/UX flow
- Data models needed
- Integration with existing features
```

### 2. 학습자 유형 시스템 구현

```
Implement the 16 Learning Types System for Hyle.

The system should:
- Have 4 dimensions: Planning (P/S), Social (I/G), Processing (V/A), Approach (T/P)
- Create 16 unique learning types (like MBTI)
- Include an 8-question test (2 per dimension)
- Each type needs: character design, personality, study tips
- Results should be shareable on social media

Current app structure:
- lib/features/learning_type/ directory exists
- User model has learningType and learningTypeDetails fields
- Design system uses MapleStory-style cute characters

Plan should include:
1. Test flow implementation
2. Character system design
3. Results calculation logic
4. Personalization engine
5. Social sharing feature
```

### 3. 게이미피케이션 시스템 확장

```
Expand the gamification system for Hyle learning app.

Current implementation:
- Basic XP system (1 minute = 1 XP)
- Level calculation exists
- Todo completion gives XP rewards

Need to add:
- Daily/Weekly/Special missions system
- Achievement badges (첫 걸음, 불타는 열정, 올빼미, etc.)
- Multiplier system (morning bonus, streak bonus, etc.)
- Mission UI with progress tracking
- Notification system for achievements

Requirements:
- Missions should reset at 4 AM
- Special event missions for exam periods
- School-specific missions capability
- All achievements should have unique animations

Please plan the implementation including data models, UI components, and state management.
```

### 4. AI 기능 통합

```
Integrate AI features into Hyle learning companion.

Key AI features needed:
1. Smart Todo Time Estimation
   - Learn from user's actual completion times
   - Consider subject difficulty
   - Account for time of day performance

2. AI Study Planner
   - Natural language input: "내일 수학 시험 준비해줘"
   - Generate optimized study schedule
   - Consider user's learning type
   - Suggest break patterns

3. Pattern Recognition
   - Identify peak productivity hours
   - Detect burnout risks
   - Recommend optimal study subjects by time

Current setup:
- No AI integration yet
- User data stored locally
- Timer data available for analysis

Plan the AI integration considering:
- Local vs cloud processing
- Data privacy
- Offline functionality
- Progressive enhancement
```

### 5. 소셜 기능 구현

```
Implement social features for Hyle learning platform.

Requirements:
1. Real-time Status System
   - Show current studying status (subject, duration, mode)
   - Custom status messages with emojis
   - Discord/Spotify-like presence

2. Friend System
   - Add friends by username/email
   - Friend suggestions based on school/subjects
   - Privacy controls

3. Study Groups/Guilds
   - Small groups (5-20 people)
   - Large guilds (50-200 people)
   - Group missions and challenges
   - Shared virtual study room

4. Study Posts & Stories
   - Share study achievements
   - 24-hour stories
   - Like and comment system

Current architecture:
- Local-first approach
- Planning AWS Amplify integration later
- Need real-time capabilities

Create implementation plan considering:
- Offline-first architecture
- Real-time sync strategy
- Privacy and moderation
- Scalability
```

### 6. 스킨 시스템 및 수익화

```
Design and implement skin system for monetization in Hyle.

Skinnable components:
1. Timer/Stopwatch skins
   - Default (free)
   - Retro Digital LED
   - Ocean waves animation
   - Matrix falling code
   - Mechanical steampunk

2. Todo list skins
   - RPG quest scroll
   - Sticky notes
   - Terminal style
   - Notebook style

3. Achievement badges
   - Medieval shields
   - Holographic
   - Pixel art

4. Profile frames and effects

Monetization model:
- Individual skins: $1.99
- Skin packs: $4.99
- Season pass: $4.99/month
- Earn through gameplay option

Technical requirements:
- Preview system
- Smooth skin switching
- Persist user selections
- Handle purchases/unlocks

Plan implementation including:
- Skin system architecture
- Preview component
- Purchase flow
- Unlock mechanism
```

## 🔧 기술적 고려사항 체크리스트

Plan Mode 사용 시 항상 포함해야 할 사항:

- [ ] 기존 디자인 시스템 활용 (AppColors, AppTypography, AppSpacing)
- [ ] Riverpod을 사용한 상태 관리
- [ ] 에러 처리 및 로딩 상태
- [ ] 크로스 플랫폼 호환성 (Web, iOS, Android)
- [ ] 오프라인 우선 접근
- [ ] 성능 최적화 고려
- [ ] 접근성 (a11y) 요구사항
- [ ] 국제화 (i18n) 준비

## 📝 Plan Mode 결과물 체크리스트

좋은 Plan Mode 결과물이 포함해야 할 것:

1. **개요**: 구현할 기능의 명확한 설명
2. **파일 구조**: 생성/수정할 파일 목록
3. **데이터 모델**: 필요한 클래스/인터페이스
4. **상태 관리**: Provider 구조 및 상태 흐름
5. **UI 플로우**: 화면 전환 및 사용자 경험
6. **통합 포인트**: 기존 기능과의 연결점
7. **테스트 전략**: 주요 테스트 케이스
8. **단계별 구현**: 우선순위가 있는 구현 순서

## 💡 유용한 컨텍스트 정보

```
프로젝트 구조:
- lib/features/[기능명]/screens/
- lib/features/[기능명]/widgets/
- lib/features/[기능명]/providers/
- lib/models/
- lib/core/theme/
- lib/core/widgets/

주요 파일:
- PROJECT_STATUS.md: 현재 개발 상황
- development_plan.json: 구조화된 개발 계획
- 디자인 시스템: core/theme/ 폴더

현재 구현된 기능:
- 퀘스트(투두) 시스템 with 통합 타이머
- 기본 대시보드
- 테마/스킨 시스템 기초
- 네비게이션 구조
```

## 🚀 완전한 시스템 구축 프롬프트

### 7. AWS 기반 전체 아키텍처 구현

```
Create Hyle - AI-Powered Learning Companion Platform with Complete AWS Architecture

=== PROJECT OVERVIEW ===
Hyle is a revolutionary AI learning platform that makes studying as engaging as gaming and as personalized as having a private tutor. Like MBTI for learning styles, we're creating a cultural phenomenon where students proudly identify with their "Learning Type."

Vision: Build a Palantir AIP-style decision support system for education, where AI provides real-time feedback for optimal learning decisions.

=== AWS ARCHITECTURE SETUP ===

1. AWS AMPLIFY FOUNDATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Initialize complete Amplify backend:

```bash
# Commands to execute
amplify init
amplify add auth
amplify add api
amplify add storage
amplify add analytics
amplify push
```

Auth Configuration (Cognito):
- Email/password authentication
- Social login ready (Google, Apple, Kakao)
- MFA optional
- Email verification required
- Password requirements: 8+ chars, uppercase, lowercase, number

API Configuration (AppSync + DynamoDB):
- GraphQL API with real-time subscriptions
- DynamoDB on-demand billing
- DataStore for offline support
- Conflict resolution: Auto-merge

Storage Configuration (S3):
- Profile images bucket
- Study materials bucket
- User-generated content bucket
- CloudFront CDN enabled

Analytics Configuration (Pinpoint):
- User behavior tracking
- Custom events for all actions
- Funnel analysis
- User segmentation

2. GRAPHQL SCHEMA (Complete)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```graphql
type User @model @auth(rules: [{allow: owner}]) {
  id: ID!
  email: String!
  nickname: String!
  learningType: LearningType
  learningTypeDetails: AWSJSON # Full 16-type analysis
  level: Int!
  xp: Int!
  totalStudyTime: Int!
  currentStreak: Int!
  longestStreak: Int!
  statusMessage: String
  profileImageUrl: String
  selectedExam: ExamType
  selectedSubjects: [String]
  targetUniversity: String
  targetMajor: String
  coins: Int!
  badges: [String]
  premiumTier: PremiumTier
  skinInventory: [String]
  currentTheme: String
  createdAt: AWSDateTime!
  updatedAt: AWSDateTime!
  friends: [Friend] @hasMany
  todos: [Todo] @hasMany
  timerSessions: [TimerSession] @hasMany
  posts: [Post] @hasMany
  stories: [Story] @hasMany
  studyGroups: [GroupMember] @hasMany
  missions: [MissionProgress] @hasMany
  aiInteractions: [AIInteraction] @hasMany
  studyInsights: [StudyInsight] @hasMany
}

type LearningType {
  planning: String! # PLANNED or SPONTANEOUS
  social: String! # INDIVIDUAL or GROUP
  processing: String! # VISUAL or AUDITORY
  approach: String! # THEORETICAL or PRACTICAL
}

type Friend @model @auth(rules: [{allow: owner}]) {
  id: ID!
  userID: ID! @index(name: "byUser")
  friendID: ID! @index(name: "byFriend")
  status: FriendStatus!
  createdAt: AWSDateTime!
  user: User @belongsTo(fields: ["userID"])
  friend: User @belongsTo(fields: ["friendID"])
}

type Todo @model @auth(rules: [{allow: owner}]) {
  id: ID!
  title: String!
  description: String
  completed: Boolean!
  priority: Priority!
  dueDate: AWSDateTime
  subject: String
  estimatedTime: Int # minutes
  actualTime: Int # minutes
  aiSuggested: Boolean
  xpReward: Int!
  completedAt: AWSDateTime
  userID: ID! @index(name: "byUser")
  user: User @belongsTo(fields: ["userID"])
}

type TimerSession @model @auth(rules: [{allow: owner}]) {
  id: ID!
  startTime: AWSDateTime!
  endTime: AWSDateTime
  pausedDuration: Int # seconds paused
  duration: Int! # total seconds
  subject: String
  type: TimerType!
  todoID: ID # linked todo if any
  notes: String # quick notes during session
  productivityScore: Float # AI calculated
  distractionCount: Int
  xpEarned: Int!
  location: String # home, school, cafe, etc
  mood: String # focused, tired, stressed, etc
  userID: ID! @index(name: "byUser")
  user: User @belongsTo(fields: ["userID"])
  events: [TimerEvent] @hasMany
}

type TimerEvent @model @auth(rules: [{allow: owner}]) {
  id: ID!
  type: EventType!
  timestamp: AWSDateTime!
  data: AWSJSON # pause reason, note content, etc
  sessionID: ID! @index(name: "bySession")
  session: TimerSession @belongsTo(fields: ["sessionID"])
}

type Post @model @auth(rules: [{allow: owner}, {allow: public, operations: [read]}]) {
  id: ID!
  type: PostType!
  content: String!
  imageUrls: [String]
  videoUrl: String
  subject: String
  tags: [String]
  likes: Int!
  viewCount: Int!
  isPublic: Boolean!
  userID: ID! @index(name: "byUser")
  user: User @belongsTo(fields: ["userID"])
  comments: [Comment] @hasMany
  createdAt: AWSDateTime!
}

type Story @model @auth(rules: [{allow: owner}, {allow: public, operations: [read]}]) {
  id: ID!
  content: String!
  mediaUrl: String!
  mediaType: MediaType!
  viewCount: Int!
  reactions: AWSJSON # emoji reactions count
  expiresAt: AWSDateTime!
  userID: ID! @index(name: "byUser")
  user: User @belongsTo(fields: ["userID"])
}

type Comment @model @auth(rules: [{allow: owner}, {allow: public, operations: [read]}]) {
  id: ID!
  content: String!
  likes: Int!
  postID: ID! @index(name: "byPost")
  userID: ID! @index(name: "byUser")
  post: Post @belongsTo(fields: ["postID"])
  user: User @belongsTo(fields: ["userID"])
  createdAt: AWSDateTime!
}

type StudyGroup @model @auth(rules: [{allow: owner}]) {
  id: ID!
  name: String!
  description: String
  groupType: GroupType!
  maxMembers: Int!
  currentMembers: Int!
  isPublic: Boolean!
  tags: [String]
  rules: String
  avatarUrl: String
  level: Int!
  totalXP: Int!
  weeklyGoal: Int # minutes
  ownerID: ID!
  createdAt: AWSDateTime!
  members: [GroupMember] @hasMany
  missions: [GroupMission] @hasMany
  posts: [GroupPost] @hasMany
}

type GroupMember @model @auth(rules: [{allow: owner}]) {
  id: ID!
  role: GroupRole!
  joinedAt: AWSDateTime!
  contribution: Int! # XP contributed to group
  weeklyStudyTime: Int!
  status: String # custom status in group
  userID: ID! @index(name: "byUser")
  groupID: ID! @index(name: "byGroup")
  user: User @belongsTo(fields: ["userID"])
  group: StudyGroup @belongsTo(fields: ["groupID"])
}

type GroupMission @model @auth(rules: [{allow: owner}]) {
  id: ID!
  title: String!
  description: String!
  type: MissionType!
  requirement: AWSJSON # specific requirements
  progress: Int!
  target: Int!
  xpReward: Int!
  coinReward: Int!
  deadline: AWSDateTime!
  completed: Boolean!
  groupID: ID! @index(name: "byGroup")
  group: StudyGroup @belongsTo(fields: ["groupID"])
}

type GroupPost @model @auth(rules: [{allow: owner}]) {
  id: ID!
  content: String!
  imageUrls: [String]
  isPinned: Boolean!
  groupID: ID! @index(name: "byGroup")
  userID: ID! @index(name: "byUser")
  group: StudyGroup @belongsTo(fields: ["groupID"])
  user: User @belongsTo(fields: ["userID"])
  createdAt: AWSDateTime!
}

type Mission @model @auth(rules: [{allow: public, operations: [read]}, {allow: owner}]) {
  id: ID!
  type: MissionType!
  title: String!
  description: String!
  requirement: AWSJSON # JSON with specific requirements
  xpReward: Int!
  coinReward: Int!
  badgeReward: String
  frequency: MissionFrequency!
  isActive: Boolean!
  order: Int!
}

type MissionProgress @model @auth(rules: [{allow: owner}]) {
  id: ID!
  progress: Int!
  target: Int!
  completed: Boolean!
  completedAt: AWSDateTime
  claimedAt: AWSDateTime
  userID: ID! @index(name: "byUser")
  missionID: ID! @index(name: "byMission")
  user: User @belongsTo(fields: ["userID"])
  mission: Mission @belongsTo(fields: ["missionID"])
}

type AIInteraction @model @auth(rules: [{allow: owner}]) {
  id: ID!
  type: AIInteractionType!
  userPrompt: String!
  aiResponse: String!
  context: AWSJSON # Current study state, etc
  feedback: String # user feedback on AI response
  helpful: Boolean
  userID: ID! @index(name: "byUser")
  user: User @belongsTo(fields: ["userID"])
  createdAt: AWSDateTime!
}

type StudyInsight @model @auth(rules: [{allow: owner}]) {
  id: ID!
  type: InsightType!
  title: String!
  description: String!
  data: AWSJSON # Charts data, statistics, etc
  importance: Int! # 1-5
  actionable: Boolean!
  dismissed: Boolean
  userID: ID! @index(name: "byUser")
  user: User @belongsTo(fields: ["userID"])
  createdAt: AWSDateTime!
}

type StudyReel @model @auth(rules: [{allow: owner}, {allow: public, operations: [read]}]) {
  id: ID!
  title: String!
  videoUrl: String!
  thumbnailUrl: String!
  duration: Int! # seconds
  subject: String!
  topic: String!
  difficulty: Difficulty!
  likes: Int!
  views: Int!
  saves: Int!
  transcript: String
  hashtags: [String]
  isPublic: Boolean!
  userID: ID! @index(name: "byUser")
  user: User @belongsTo(fields: ["userID"])
  createdAt: AWSDateTime!
}

# Enums
enum ExamType {
  CSAT # 수능
  SAT
  AP
  ALEVEL
  IBDP
  TOEIC
  TOEFL
  IELTS
  OTHER
}

enum PremiumTier {
  FREE
  PREMIUM
  PREMIUM_PLUS
}

enum Priority {
  HIGH
  MEDIUM
  LOW
}

enum TimerType {
  STOPWATCH
  TIMER
  POMODORO
}

enum EventType {
  START
  PAUSE
  RESUME
  END
  NOTE_ADDED
  DISTRACTION
}

enum FriendStatus {
  PENDING
  ACCEPTED
  BLOCKED
}

enum PostType {
  STUDY_PROOF
  NOTES
  QUESTION
  ACHIEVEMENT
  TIP
}

enum MediaType {
  IMAGE
  VIDEO
}

enum GroupType {
  STUDY_GROUP # 5-20 members
  GUILD # 50-200 members
  SCHOOL_OFFICIAL
  EXAM_PREP
}

enum GroupRole {
  OWNER
  ADMIN
  MODERATOR
  MEMBER
}

enum MissionType {
  DAILY
  WEEKLY
  SPECIAL
  GROUP
  HIDDEN
}

enum MissionFrequency {
  ONCE
  DAILY
  WEEKLY
  MONTHLY
}

enum AIInteractionType {
  PLANNER
  TUTOR
  MOTIVATION
  ANALYSIS
  RECOMMENDATION
}

enum InsightType {
  PATTERN
  WARNING
  ACHIEVEMENT
  RECOMMENDATION
  MILESTONE
}

enum Difficulty {
  BEGINNER
  INTERMEDIATE
  ADVANCED
  EXPERT
}
```

3. ADDITIONAL AWS SERVICES INTEGRATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

A. Real-time Event Processing (Kinesis)
```typescript
// Setup Kinesis Data Streams for real-time analytics
const eventStream = {
  streamName: 'hyle-study-events',
  shardCount: 2,
  events: [
    'timer_start', 'timer_pause', 'timer_end',
    'todo_created', 'todo_completed',
    'note_added', 'break_taken',
    'focus_score_calculated',
    'achievement_unlocked'
  ]
}

// Lambda function to process events
exports.processStudyEvent = async (event) => {
  // Parse Kinesis records
  // Update user metrics
  // Trigger AI analysis if needed
  // Store in DynamoDB/Neptune
}
```

B. AI Integration (Bedrock + SageMaker)
```typescript
// Bedrock Configuration for Claude
const bedrockConfig = {
  model: 'anthropic.claude-3-opus-20240229',
  region: 'us-east-1',
  maxTokens: 4096,
  temperature: 0.7
}

// AI Tutor Functions
interface AITutorFunctions {
  analyzeLearningPattern(userId: string): Promise<LearningInsight>
  generateStudyPlan(prompt: string, context: UserContext): Promise<StudyPlan>
  provideRealtimeFeedback(session: StudySession): Promise<Feedback>
  predictNextBestAction(currentState: StudyState): Promise<Action>
}

// SageMaker Custom Models
const customModels = {
  productivityPredictor: 'hyle-productivity-model',
  difficultyEstimator: 'hyle-difficulty-model',
  retentionPredictor: 'hyle-retention-model'
}
```

C. Knowledge Graph (Neptune)
```typescript
// Neptune Graph Structure
interface KnowledgeGraph {
  nodes: {
    users: UserNode[]
    subjects: SubjectNode[]
    concepts: ConceptNode[]
    learningPaths: PathNode[]
  }
  edges: {
    studies: StudiesEdge[] // user -> subject
    requires: RequiresEdge[] // concept -> concept
    mastered: MasteredEdge[] // user -> concept
    similarTo: SimilarEdge[] // user -> user
  }
}

// Graph Queries
const graphQueries = {
  findPrerequisites: `
    MATCH (c:Concept {id: $conceptId})<-[:REQUIRES*]-(prereq:Concept)
    RETURN prereq
  `,
  findSimilarUsers: `
    MATCH (u1:User {id: $userId})-[:STUDIES]->(s:Subject)<-[:STUDIES]-(u2:User)
    WHERE u1.learningType = u2.learningType
    RETURN u2 LIMIT 10
  `,
  recommendNextConcept: `
    MATCH (u:User {id: $userId})-[:MASTERED]->(c:Concept)-[:LEADS_TO]->(next:Concept)
    WHERE NOT (u)-[:MASTERED]->(next)
    RETURN next ORDER BY next.difficulty LIMIT 3
  `
}
```

D. Vector Database (Pinecone Integration)
```typescript
// Pinecone Configuration
const pineconeConfig = {
  environment: 'us-east1-gcp',
  apiKey: process.env.PINECONE_API_KEY,
  indexes: {
    studyPatterns: {
      dimension: 768,
      metric: 'cosine',
      pods: 1
    },
    contentEmbeddings: {
      dimension: 1536,
      metric: 'dotproduct',
      pods: 2
    }
  }
}

// Embedding Structure
interface StudyEmbedding {
  id: string
  vector: number[]
  metadata: {
    userId: string
    timestamp: string
    subject: string
    productivity: number
    duration: number
    context: any
  }
}

// RAG Pipeline
class RAGPipeline {
  async findSimilarPatterns(currentSession: StudySession): Promise<Pattern[]>
  async getRelevantContent(query: string): Promise<Content[]>
  async generatePersonalizedAdvice(context: UserContext): Promise<string>
}
```

E. Push Notifications (SNS)
```typescript
// SNS Configuration
const snsConfig = {
  platformApplications: {
    ios: 'arn:aws:sns:region:account:app/APNS/HyleIOS',
    android: 'arn:aws:sns:region:account:app/FCM/HyleAndroid'
  },
  topics: {
    dailyReminders: 'hyle-daily-reminders',
    achievements: 'hyle-achievements',
    friendActivity: 'hyle-friend-activity'
  }
}

// Notification Types
interface NotificationService {
  sendDailyMission(userId: string): Promise<void>
  sendStreakReminder(userId: string, currentStreak: number): Promise<void>
  sendAchievement(userId: string, achievement: Achievement): Promise<void>
  sendSmartReminder(userId: string, context: StudyContext): Promise<void>
}
```

F. Background Jobs (Lambda + EventBridge)
```typescript
// Scheduled Lambda Functions
const scheduledJobs = {
  resetDailyMissions: {
    schedule: 'cron(0 4 * * ? *)', // 4 AM KST daily
    handler: 'resetDailyMissions'
  },
  calculateWeeklyInsights: {
    schedule: 'cron(0 0 ? * MON *)', // Monday midnight
    handler: 'generateWeeklyReport'
  },
  sendSmartReminders: {
    schedule: 'rate(1 hour)',
    handler: 'checkAndSendReminders'
  },
  cleanupExpiredStories: {
    schedule: 'rate(1 hour)',
    handler: 'removeExpiredStories'
  }
}
```

4. FLUTTER APP IMPLEMENTATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Project Structure:
```
lib/
├── main.dart
├── app.dart
├── amplifyconfiguration.dart
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_themes.dart
│   │   ├── learning_types.dart
│   │   └── missions.dart
│   ├── utils/
│   │   ├── responsive.dart
│   │   ├── validators.dart
│   │   ├── formatters.dart
│   │   └── debouncer.dart
│   └── errors/
│       └── app_exceptions.dart
│
├── data/
│   ├── models/
│   │   ├── amplify_models/ (auto-generated)
│   │   └── view_models/
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── user_repository.dart
│   │   ├── timer_repository.dart
│   │   ├── todo_repository.dart
│   │   └── ai_repository.dart
│   └── services/
│       ├── amplify_service.dart
│       ├── ai_service.dart
│       ├── notification_service.dart
│       ├── analytics_service.dart
│       └── background_service.dart
│
├── domain/
│   ├── entities/
│   ├── usecases/
│   └── repositories/
│
├── presentation/
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── user_provider.dart
│   │   ├── timer_provider.dart
│   │   ├── todo_provider.dart
│   │   ├── mission_provider.dart
│   │   ├── theme_provider.dart
│   │   └── ai_provider.dart
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── splash_screen.dart
│   │   │   ├── login_screen.dart
│   │   │   ├── signup_screen.dart
│   │   │   └── forgot_password_screen.dart
│   │   ├── onboarding/
│   │   │   ├── welcome_screen.dart
│   │   │   ├── learning_type_test_screen.dart
│   │   │   └── onboarding_complete_screen.dart
│   │   ├── main/
│   │   │   ├── main_screen.dart
│   │   │   ├── home_tab.dart
│   │   │   ├── timer_tab.dart
│   │   │   ├── todo_tab.dart
│   │   │   ├── social_tab.dart
│   │   │   └── profile_tab.dart
│   │   ├── timer/
│   │   │   ├── stopwatch_screen.dart
│   │   │   ├── timer_screen.dart
│   │   │   └── pomodoro_screen.dart
│   │   ├── todo/
│   │   │   ├── todo_list_screen.dart
│   │   │   ├── todo_detail_screen.dart
│   │   │   └── todo_create_screen.dart
│   │   ├── social/
│   │   │   ├── friends_screen.dart
│   │   │   ├── posts_feed_screen.dart
│   │   │   ├── stories_screen.dart
│   │   │   ├── groups_screen.dart
│   │   │   └── reels_screen.dart
│   │   ├── ai/
│   │   │   ├── ai_planner_screen.dart
│   │   │   ├── ai_tutor_chat_screen.dart
│   │   │   └── insights_screen.dart
│   │   ├── profile/
│   │   │   ├── profile_screen.dart
│   │   │   ├── settings_screen.dart
│   │   │   ├── achievements_screen.dart
│   │   │   └── shop_screen.dart
│   │   └── premium/
│   │       └── subscription_screen.dart
│   ├── widgets/
│   │   ├── common/
│   │   │   ├── loading_widget.dart
│   │   │   ├── error_widget.dart
│   │   │   ├── empty_state_widget.dart
│   │   │   └── custom_button.dart
│   │   ├── cards/
│   │   │   ├── mission_card.dart
│   │   │   ├── friend_card.dart
│   │   │   ├── post_card.dart
│   │   │   └── achievement_card.dart
│   │   ├── dialogs/
│   │   │   ├── confirm_dialog.dart
│   │   │   ├── reward_dialog.dart
│   │   │   └── level_up_dialog.dart
│   │   └── animations/
│   │       ├── confetti_animation.dart
│   │       ├── level_up_animation.dart
│   │       └── streak_animation.dart
│   └── theme/
│       ├── app_theme.dart
│       ├── text_styles.dart
│       └── animations.dart
│
└── router/
    └── app_router.dart
```

5. KEY FEATURES IMPLEMENTATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

A. Learning Type System (16 Types)
- 8 situational questions
- 4 dimensions analysis
- Character assignment
- Personalized study tips
- Share functionality

B. Timer Module
- Stopwatch with pause/resume
- Timer with custom duration
- Pomodoro with customizable cycles
- Background operation
- Subject tracking
- Real-time XP calculation
- Auto-save every 30 seconds

C. Smart Todo System
- CRUD operations
- Priority levels
- Subject categorization
- Time estimation
- AI suggestions
- Drag to reorder
- Swipe actions
- Link to timer

D. Gamification Engine
- XP calculation with multipliers
- Level system (1-100)
- Daily missions
- Weekly challenges
- Achievement badges
- Streak tracking
- Coin economy
- Leaderboards

E. AI Features
- Natural language planner
- Real-time study coaching
- Pattern recognition
- Predictive suggestions
- Learning insights
- Difficulty adjustment
- Smart reminders

F. Social Features
- Friend system
- Real-time status
- Study posts/stories
- Study groups/guilds
- Comments/likes
- Study Reels
- Group missions
- Virtual study rooms

G. Customization
- Theme system
- Skin marketplace
- Avatar customization
- Profile themes
- Timer skins
- Achievement displays

H. Premium Features
- Unlimited AI tutoring
- Advanced analytics
- Premium skins
- Priority support
- Group creation
- Export reports

6. PERFORMANCE & OPTIMIZATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

- App size < 50MB
- Cold start < 2 seconds
- 60 FPS animations
- Offline support for core features
- Background timer accuracy
- Battery optimization
- Memory management
- Cache strategy

7. MONETIZATION SETUP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

In-App Purchases:
- Premium Monthly: $4.99
- Premium Plus Monthly: $9.99
- Premium Yearly: $49.99
- Coin Packs: $0.99 - $99.99
- Skin Packs: $1.99 - $9.99

Revenue Streams:
- Subscriptions (70%)
- In-app purchases (20%)
- B2B licenses (10%)

8. ANALYTICS EVENTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Track everything:
- User registration
- Learning type completion
- Timer sessions
- Todo interactions
- Mission completions
- Social interactions
- AI usage
- Purchase events
- Retention metrics

9. DEPLOYMENT CONFIGURATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Environments:
- Development (dev)
- Staging (staging)
- Production (prod)

Build Flavors:
- Free version
- Premium version
- School version

Please implement this complete system starting with:
1. Flutter project setup with all packages
2. AWS Amplify initialization and configuration
3. Core authentication flow
4. Main app structure
5. MVP features implementation

Remember to make it scalable, maintainable, and ready for rapid iteration based on user feedback.
```

---

## 📅 Development Progress Log

### 2025-01-17: AI Learning Services Complete Implementation

**완료된 작업:**
1. **AWS Infrastructure Setup**
   - Neptune Graph Database 클라이언트 구현
   - Pinecone Vector Database 연동
   - 5개 Lambda Functions 작성
     - embeddingFunction (Amazon Titan)
     - graphQueryFunction (Neptune queries)
     - aiTutorFunction (메인 AI 튜터)
     - curriculumFunction (커리큘럼 관리)
     - realtimeProcessingFunction (실시간 처리)

2. **26 Flutter Service Files Created**
   - **Infrastructure Layer (6)**: 온톨로지, 데이터 융합, 커리큘럼 관리
   - **Predictive Analytics (1)**: ML 기반 예측 서비스
   - **Learning Pattern Analysis (4)**: 학습 패턴, 인지 부하, 집중도, 실수 패턴
   - **Session & Feedback (4)**: 세션 피드백, 진도 시각화, 성취도, 학습 일지
   - **Problem Analysis (4)**: IRT 난이도 분석, 솔루션 평가, 적응형 평가, 성과 지표
   - **Notification & Nudge (4)**: 스마트 알림, 행동 넛지, 동기부여, 개입 타이밍
   - **Integration Orchestration (3)**: AI 튜터, 데이터 통합, 실시간 개입 오케스트레이터

3. **Key Features Implemented**
   - RAG Pipeline (Neptune + Pinecone)
   - 실시간 학습 모니터링 시스템
   - 행동과학 기반 개입 엔진
   - 적응형 학습 평가 시스템
   - 통합 데이터 수집 및 분석

**다음 작업:**
- GraphQL API 완전 구성
- S3 스토리지 버킷 설정
- Flutter 앱 인증 플로우 업데이트

---

이 가이드를 사용하여 Claude Code Plan Mode에서 더 정확하고 상세한 계획을 받을 수 있습니다.