# 스크린샷 리사이즈 도구

App Store 제출용 스크린샷을 1284x2778 (iPhone 6.5인치) 규격으로 일괄 리사이즈하는 도구입니다.

## 사전 준비 (최초 1회)

### 1. uv 설치

uv는 Python 패키지 관리 도구입니다. 터미널에서 아래 명령어를 실행하세요.

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

설치 후 터미널을 재시작하거나 아래 명령어를 실행하세요.

```bash
source $HOME/.local/bin/env
```

설치 확인:

```bash
uv --version
```

### 2. 프로젝트 환경 설정

프로젝트 폴더로 이동 후 의존성을 설치합니다.

```bash
cd /Users/izowooi/git/hell-timer/python-proj
uv sync
```

## 사용 방법

### 1. 입력 폴더 준비

리사이즈할 이미지들을 폴더에 넣습니다. (PNG, JPG 지원)

```
python-proj/
├── input/          <- 원본 이미지를 여기에 넣으세요
│   ├── screenshot1.png
│   ├── screenshot2.png
│   └── ...
└── main.py
```

### 2. 실행

```bash
uv run python main.py input
```

`input` 부분은 실제 폴더 이름으로 변경하세요.

### 3. 결과 확인

리사이즈된 이미지는 `out` 폴더에 저장됩니다.

```
python-proj/
├── input/
├── out/            <- 결과물이 여기에 생성됩니다
│   ├── screenshot1.png
│   └── screenshot2.png
└── main.py
```

## 실행 예시

```bash
$ uv run python main.py input

총 3개 이미지 처리
출력 폴더: /Users/izowooi/git/hell-timer/python-proj/out

[1/3] screenshot1.png
  1290x2796 -> 1284x2778
[2/3] screenshot2.png
  1290x2796 -> 1284x2778
[3/3] screenshot3.png
  1290x2796 -> 1284x2778

완료!
```

## 문제 해결

### "uv: command not found" 오류

uv가 설치되지 않았거나 PATH에 없습니다. 위 "uv 설치" 단계를 다시 진행하세요.

### "입력 폴더가 존재하지 않습니다" 오류

폴더 이름이 정확한지 확인하세요. 현재 위치(python-proj 폴더)에서 상대 경로로 입력합니다.

### 이미지가 처리되지 않음

지원 형식: `.png`, `.jpg`, `.jpeg` (대소문자 무관)
