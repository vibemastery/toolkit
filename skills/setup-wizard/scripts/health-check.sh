#!/bin/bash
# health-check.sh — Verify that the VibeMastery project environment is working
#
# Usage: bash health-check.sh [project-name]
#   project-name  Optional. If provided, also checks the local .test domain.
#
# Exits with 0 if all checks pass, 1 if any fail.

PROJECT_NAME="${1:-}"
PASS=0
FAIL=0

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

check() {
    local label="$1"
    local cmd="$2"
    local hint="$3"

    if eval "$cmd" &>/dev/null 2>&1; then
        echo -e "${GREEN}✓${RESET} $label"
        ((PASS++))
    else
        echo -e "${RED}✗${RESET} $label"
        echo -e "  ${YELLOW}→ $hint${RESET}"
        ((FAIL++))
    fi
}

echo ""
echo "Running environment checks..."
echo "─────────────────────────────"

check \
    "PHP is installed" \
    "php -v" \
    "Close this terminal, open a new one, and try again. If it still fails, open Laravel Herd and click 'Repair'."

check \
    "Composer is installed" \
    "composer --version" \
    "Open Laravel Herd → Settings → click 'Repair'. Then open a new terminal."

check \
    "Node.js is installed" \
    "node -v" \
    "Open Laravel Herd → Node → click 'Install'. Then open a new terminal."

check \
    "NPM is installed" \
    "npm -v" \
    "Node and NPM install together. Try opening a new terminal, or run 'herd repair'."

check \
    "Laravel is responding" \
    "php artisan --version" \
    "Make sure you are inside your project folder (cd ~/Projects/YOUR_PROJECT_NAME)."

check \
    "Node packages installed" \
    "test -d node_modules" \
    "Run: npm install"

check \
    "PHP packages installed" \
    "test -d vendor" \
    "Run: composer install"

check \
    "Database file exists" \
    "test -f database/database.sqlite" \
    "Run: php artisan migrate"

if [ -n "$PROJECT_NAME" ]; then
    check \
        "Local domain ($PROJECT_NAME.test) resolves" \
        "curl -sf --max-time 5 https://$PROJECT_NAME.test" \
        "Make sure Laravel Herd is running and you ran 'herd link' inside your project folder. Try opening $PROJECT_NAME.test in your browser manually."
fi

echo "─────────────────────────────"

if [ "$FAIL" -eq 0 ]; then
    echo -e "${GREEN}All $PASS checks passed! Your environment is ready.${RESET}"
else
    echo -e "${RED}$FAIL check(s) failed.${RESET} See the hints above to fix them."
    echo "Once fixed, run this check again: bash .claude/skills/setup-wizard/scripts/health-check.sh $PROJECT_NAME"
fi

echo ""
exit "$FAIL"
