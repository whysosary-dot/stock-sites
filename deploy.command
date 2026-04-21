#!/bin/bash
# Stock-Sites 배포 스크립트
# 처음 실행 시: GitHub repo 생성 + push
# 이후 실행 시: 변경사항 commit + push
# 사용법: Finder에서 이 파일을 더블클릭하세요.

set -e
cd "$(dirname "$0")"

REPO_NAME="stock-sites"

echo "============================================"
echo "  Stock Sites 배포"
echo "============================================"
echo ""

# gh CLI 확인
if ! command -v gh >/dev/null 2>&1; then
  echo "❌ 'gh' (GitHub CLI) 가 설치되어 있지 않습니다."
  echo "   설치: brew install gh"
  echo ""
  read -p "종료하려면 Enter..."
  exit 1
fi

# 인증 확인
if ! gh auth status >/dev/null 2>&1; then
  echo "❌ GitHub 로그인이 필요합니다."
  echo "   실행: gh auth login"
  echo ""
  read -p "종료하려면 Enter..."
  exit 1
fi

# 1) 원격 저장소가 없다면 GitHub에 repo를 만들고 연결
if ! git remote get-url origin >/dev/null 2>&1; then
  echo "📦 GitHub에 '$REPO_NAME' repo 생성 중..."
  gh repo create "$REPO_NAME" --public --source=. --remote=origin --push
  echo ""
  echo "🌐 GitHub Pages 활성화 중..."
  gh api -X POST "repos/{owner}/$REPO_NAME/pages" \
    -f "source[branch]=main" \
    -f "source[path]=/" >/dev/null 2>&1 || true
  OWNER=$(gh api user -q .login)
  echo ""
  echo "✅ 배포 완료!"
  echo "   Repo : https://github.com/$OWNER/$REPO_NAME"
  echo "   Pages: https://$OWNER.github.io/$REPO_NAME/  (1~2분 후 활성화)"
else
  # 2) 이미 연결돼 있으면 변경사항만 push
  echo "🔄 변경사항 확인 중..."
  if [[ -n "$(git status --porcelain)" ]]; then
    git add .
    git commit -m "update: 사이트 목록 업데이트 $(date +%Y-%m-%d)"
  fi
  echo "⬆️  GitHub로 push..."
  git push -u origin main
  echo ""
  echo "✅ push 완료!"
fi

echo ""
read -p "창을 닫으려면 Enter..."
