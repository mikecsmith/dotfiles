if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI (gh) is not installed. Please install it and authenticate with the correct scopes - minimally: gh auth login -s read:projects,read:packages"
  exit 1
fi
