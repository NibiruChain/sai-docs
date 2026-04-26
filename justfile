# Displays available recipes by running `just -l`.
setup:
  #!/usr/bin/env bash
  just -l

# Install Bun for local docs preview commands.
i-bun:
  #!/usr/bin/env bash
  set -euo pipefail

  if command -v bun >/dev/null 2>&1; then
    echo "bun $(bun --version) is installed"
    exit 0
  fi

  echo "Installing bun with npm"
  echo "Installation guide: https://bun.com/docs/installation"
  npm install --global bun@1.3.13
  bun --version

# Preview the GitBook docs locally with Docsify. (See .cursor/skills/gitbook-preview)
gitbook-preview:
  just i-bun
  bunx --bun docsify-cli@4.4.4 serve . -p 4000 -i README.md
