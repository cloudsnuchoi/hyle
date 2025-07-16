# GitHub 저장소 설정 가이드

## 1. GitHub에서 새 저장소 만들기

1. GitHub.com에 로그인
2. 우측 상단 '+' 버튼 클릭 → 'New repository' 선택
3. Repository name: `hyle`
4. Description: "AI Learning Companion - 학습을 게임처럼 재미있게"
5. Public 선택
6. **DO NOT** initialize with README, .gitignore, or license
7. 'Create repository' 클릭

## 2. 로컬 저장소를 GitHub에 연결하기

GitHub에서 저장소를 만든 후, 터미널에서 다음 명령어를 실행하세요:

```bash
# 현재 프로젝트 디렉토리에서
cd /Users/junhoochoi/dev/github\ desktop/hyle

# GitHub 저장소를 remote로 추가 (YOUR_USERNAME을 실제 GitHub 사용자명으로 변경)
git remote add origin https://github.com/YOUR_USERNAME/hyle.git

# 또는 SSH를 사용하는 경우
git remote add origin git@github.com:YOUR_USERNAME/hyle.git

# main 브랜치를 GitHub에 푸시
git push -u origin main
```

## 3. Windows에서 클론하기

Windows 컴퓨터에서:

```bash
# 프로젝트를 클론
git clone https://github.com/YOUR_USERNAME/hyle.git
cd hyle

# Flutter 의존성 설치
flutter pub get

# 개발 모드로 실행
flutter run -d chrome -t lib/main_dev.dart
```

## 4. 개발 시 주의사항

### Mac과 Windows 모두에서 개발할 때:

1. **줄 끝 문자(Line Endings)**
   - Git이 자동으로 처리하도록 설정되어 있음
   - 문제가 생기면: `git config core.autocrlf true` (Windows)

2. **경로 구분자**
   - Flutter가 자동으로 처리함
   - 코드에서 경로 작성 시 `path` 패키지 사용 권장

3. **플랫폼별 파일**
   - `.dart_tool/`, `build/` 등은 .gitignore에 포함되어 있음
   - 각 플랫폼에서 별도로 생성됨

4. **동기화**
   - 작업 전: `git pull`
   - 작업 후: `git add .` → `git commit -m "message"` → `git push`

## 5. 추가 팁

- **브랜치 사용**: 기능별로 브랜치를 만들어 작업
  ```bash
  git checkout -b feature/new-feature
  # 작업 후
  git push origin feature/new-feature
  ```

- **충돌 방지**: 동시에 같은 파일을 편집하지 않도록 주의

- **IDE 설정**: 각 플랫폼의 IDE 설정은 로컬에서 관리 (.vscode는 공유됨)