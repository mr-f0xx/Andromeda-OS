#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/dpkg" "$tmp/state"
# Replace only the absolute paths so the actual setup script can run unprivileged.
sed -e "s|/var/lib/dpkg/info/pt35-desktop.postinst|$tmp/dpkg/postinst|g" \
    -e "s|/usr/bin/pt35-ai|$tmp/bin/pt35-ai|g" \
    -e "s|/var/lib/pt35-ai|$tmp/ai-state|g" \
    -e "s|/var/lib/pt35|$tmp/state|g" \
    "$root/image/stage2/05-pt35/files/pt35-image-setup" > "$tmp/setup"
cat > "$tmp/bin/getent" <<'MOCK'
#!/bin/sh
[ "${TEST_USER:-}" ] && printf '%s:x:1000:1000::/home/%s:/bin/bash\n' "$TEST_USER" "$TEST_USER"
exit 0
MOCK
cat > "$tmp/bin/passwd" <<'MOCK'
#!/bin/sh
printf '%s %s\n' "$2" "$TEST_STATUS"
MOCK
cat > "$tmp/dpkg/postinst" <<'MOCK'
#!/bin/sh
[ "$1" = configure ]
printf '%s\n' "$PT35_USER" > "$TEST_RESULT"
MOCK
cat > "$tmp/bin/pt35-ai" <<'MOCK'
#!/bin/sh
[ "$1" = image-configure ]
printf '%s\n' "$PT35_USER" > "$TEST_AI_RESULT"
[ "${TEST_AI_FAIL:-0}" = 0 ]
MOCK
chmod +x "$tmp/bin/getent" "$tmp/bin/passwd" "$tmp/bin/pt35-ai" "$tmp/dpkg/postinst"
export PATH="$tmp/bin:$PATH" TEST_RESULT="$tmp/result" TEST_AI_RESULT="$tmp/ai-result"
install -d "$tmp/ai-state"
printf '4096\n' > "$tmp/ai-state/target-ram"
export TEST_USER='' TEST_STATUS=L
if sh "$tmp/setup"; then echo 'missing user was accepted' >&2; exit 1; fi
export TEST_USER=pi
if sh "$tmp/setup"; then echo 'locked user was accepted' >&2; exit 1; fi
test ! -e "$tmp/state/image-configured"
test ! -e "$tmp/result"
export TEST_USER=chosenuser TEST_STATUS=P
if TEST_AI_FAIL=1 sh "$tmp/setup"; then echo 'failed AI setup was accepted' >&2; exit 1; fi
test ! -e "$tmp/state/image-configured"
sh "$tmp/setup"
test "$(cat "$tmp/result")" = chosenuser
test "$(cat "$tmp/ai-result")" = chosenuser
test -f "$tmp/state/image-configured"
echo 'First-boot setup tests passed.'
