#!/usr/bin/env bash
# Builds the Lab 1 scenario. Usage: bash setup-lab1.sh [target-dir]
set -e
LAB="${1:-$HOME/lab1}"
rm -rf "$LAB"; mkdir -p "$LAB"; cd "$LAB"

git init -q --bare remote.git
git --git-dir=remote.git symbolic-ref HEAD refs/heads/main
git clone -q remote.git payment-service 2>/dev/null
cd payment-service
git config user.name  "Dev A"
git config user.email "dev.a@example.com"
git checkout -q -b main

# --- main: initial commit
mkdir -p config src
cat > config/application.yml <<'YML'
server:
  port: 8080
logging:
  level: INFO
YML
echo 'print("payment-service started")' > src/app.py
git add . && git commit -qm "Initial payment-service"

# --- release/v2.4
git checkout -q -b release/v2.4
sed -i 's/level: INFO/level: WARN/' config/application.yml
git commit -qam "Prepare release v2.4"

# --- feature/payment-retry (Developer A leaks the secret here)
git checkout -q -b feature/payment-retry
cat >> config/application.yml <<'YML'
payment:
  retry_max: 3
  api_key: LAB-SECRET-9f3a7c21d5e84b6a
YML
git commit -qam "Add payment retry config"
echo 'def retry(fn, n=3): ...' > src/retry.py
git add . && git commit -qm "Add retry logic"
SECRET_TIP=$(git rev-parse HEAD)
sed -i 's/api_key: .*/api_key: ${PAYMENT_API_KEY}/' config/application.yml
git commit -qam "Remove secret from application.yml"

# --- feature/logging (Dev B branched from Dev A's work in progress)
git checkout -q -b feature/logging "$SECRET_TIP"
git config user.name "Dev B"; git config user.email "dev.b@example.com"
echo 'import logging' > src/logging_setup.py
git add . && git commit -qm "Add structured logging"
sed -i 's/level: WARN/level: DEBUG/' config/application.yml
git commit -qam "Raise log level to DEBUG"

# --- release/v2.4 receives feature/payment-retry
git config user.name "Dev A"; git config user.email "dev.a@example.com"
git checkout -q release/v2.4
git merge -q --no-ff feature/payment-retry -m "Merge feature/payment-retry"

# --- main gets release/v2.4 only PARTIALLY (everything except the cleanup commit)
git checkout -q main
git merge -q --no-ff 'feature/payment-retry~1' \
    -m "Partial merge of release/v2.4 into main"
sed -i 's/level: WARN/level: ERROR/' config/application.yml
git commit -qam "Set production log level to ERROR"

git push -q origin --all

# --- someone rebases feature/logging onto main -> conflict
git config user.name "Dev B"; git config user.email "dev.b@example.com"
git checkout -q feature/logging
git rebase main >/dev/null 2>&1 || true
echo
echo "Lab ready: $LAB/payment-service"
echo "A rebase of feature/logging onto main has STOPPED with a conflict."
git status -sb | head -5
