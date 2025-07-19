# Hyle AI 기능 베타 테스트 가이드

## 데이터 파이프라인 아키텍처

현재 Hyle 앱에는 AI 기능을 위한 포괄적인 데이터 파이프라인이 이미 구축되어 있습니다:

### 1. **핵심 서비스**
- **Data Fusion Service**: 타이머, 할 일, 노트, 플래시카드 등 모든 학습 데이터를 통합
- **AI Service**: AWS Bedrock (Claude)와 GraphQL을 통해 연동
- **AI Tutor Orchestrator**: 20개 이상의 전문 서비스를 통합 관리
- **Realtime Intervention Orchestrator**: 실시간 학습 모니터링 및 개입

### 2. **백엔드 인프라**
- AWS Lambda 함수로 AI 처리
- DynamoDB로 사용자 데이터 저장
- Neptune로 지식 그래프 관리
- Pinecone으로 벡터 임베딩 저장

## 베타 테스트 시작하기

### 1. Amplify 설정 (관리자용)

`lib/amplifyconfiguration.dart` 파일의 placeholder 값들을 실제 AWS 리소스 정보로 업데이트하세요:

```dart
const amplifyConfig = ''' {
    "auth": {
        "plugins": {
            "awsCognitoAuthPlugin": {
                "CognitoUserPool": {
                    "Default": {
                        "PoolId": "실제_USER_POOL_ID",
                        "AppClientId": "실제_APP_CLIENT_ID",
                        "Region": "us-east-1"
                    }
                }
            }
        }
    },
    "api": {
        "plugins": {
            "awsAPIPlugin": {
                "hyle": {
                    "endpoint": "실제_GRAPHQL_ENDPOINT",
                    "apiKey": "실제_API_KEY"
                },
                "aiTutorAPI": {
                    "endpoint": "실제_REST_API_ENDPOINT"
                }
            }
        }
    }
}''';
```

### 2. 베타 테스터를 위한 AI 기능 접근

1. 앱을 실행하고 로그인
2. 프로필 화면으로 이동
3. "AI 기능 베타 테스트" 버튼 클릭
4. Amplify 구성하기 버튼 클릭 (최초 1회)
5. AI 기능 테스트 시작

### 3. 사용 가능한 AI 기능

#### AI 학습 계획 생성
- 자연어로 학습 요청 입력
- 예: "내일 수학 시험이 있어요. 오늘 3시간 공부할 수 있습니다."
- AI가 개인화된 학습 계획 생성

#### 실시간 세션 분석
- 학습 중 생산성과 집중도 실시간 모니터링
- 휴식 시간 추천
- 다음 최적 행동 제안

#### 학습 패턴 분석
- 가장 생산적인 시간대 파악
- 선호 과목 분석
- 학습 일관성 점수 계산

#### 실시간 개입
- 인지 과부하 감지 시 휴식 제안
- 주의력 저하 시 집중력 회복 넛지
- 문제에 막혔을 때 AI 튜터 지원

### 4. 테스트 시나리오

1. **기본 테스트**
   - AI 기능 화면에서 "AI 기능 테스트" 버튼 클릭
   - 성공 메시지와 생성된 학습 계획 확인

2. **학습 계획 생성 테스트**
   - AI 학습 플래너 열기
   - 다양한 요청 입력 테스트
   - 생성된 계획의 품질 확인

3. **실시간 모니터링 테스트**
   - 타이머 시작 후 학습 진행
   - 장시간 학습 시 휴식 알림 확인
   - 집중도 저하 시 개입 확인

### 5. 피드백 수집 항목

- AI 응답의 정확성과 유용성
- 응답 속도
- 한국어 처리 품질
- 개인화 수준
- UI/UX 개선 사항

### 6. 현재 Mock 데이터 모드

Amplify가 완전히 구성되지 않은 경우, AI Service는 자동으로 mock 데이터를 반환합니다:
- 학습 계획: 3개의 샘플 작업 생성
- 추천사항: 한국어 학습 팁 제공
- 테스트 목적으로 충분한 기능 제공

### 7. 문제 해결

**"Amplify 구성 실패" 오류**
- 인터넷 연결 확인
- amplifyconfig의 설정값 확인
- 콘솔 로그에서 상세 오류 확인

**AI 기능이 작동하지 않음**
- 로그인 상태 확인
- Amplify 구성 상태 확인
- 네트워크 연결 확인

### 8. 다음 단계

1. AWS 리소스 설정 완료
2. 실제 API 엔드포인트 연결
3. 베타 테스터 모집 및 피드백 수집
4. UI/UX 개선사항 적용
5. 정식 출시 준비

## 보안 참고사항

- API 키와 엔드포인트는 환경 변수로 관리
- 사용자 데이터는 암호화되어 저장
- 모든 API 호출은 인증된 사용자만 가능

## 연락처

문제나 제안사항이 있으시면 개발팀에 연락해주세요.