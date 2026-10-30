#!/usr/bin/env bash
# Exercise the image's target-RAM sizing and shipped agent configuration without
# downloading a model, starting a service, or needing a Raspberry Pi.
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
# shellcheck source=../scripts/pt35-ai
source "$root/scripts/pt35-ai"
STATE="$tmp/state"
MODELS="$STATE/models"
CONF="$STATE/llama-swap.yaml"
DEFAULT="$STATE/default"
# Used by cmd_agents from the sourced script.
# shellcheck disable=SC2034
PRESETS="$root/config/ai/darkwire-agents.yaml"
install -d "$MODELS"
: > "$MODELS/MiniCPM5-2B-Q4_0.gguf"
printf 'minicpm5-2b\n' > "$DEFAULT"

printf '4096\n' > "$STATE/target-ram"
model_info minicpm5-2b
test "$(ram_mb)" = 4096
test "$(kv_type)" = f16
test "$(model_ctx)" = 16384
write_config
PYTHONPATH="${PYTHONPATH:-}" python3 - "$CONF" <<'PY'
import sys, yaml
cfg = yaml.safe_load(open(sys.argv[1]))
assert list(cfg["models"]) == ["minicpm5-2b"]
cmd = cfg["models"]["minicpm5-2b"]["cmd"]
assert "--ctx-size 16384" in cmd
assert "--cache-type-k f16" in cfg["macros"]["server"]
assert "--host 127.0.0.1" in cfg["macros"]["server"]
assert "--parallel 1" in cfg["macros"]["server"]
assert cfg["globalTTL"] == 900
PY

# The finished image must keep its target sizing even on a larger build host,
# and across later model switches. An explicit image-provision override wins.
printf '8192\n' > "$STATE/target-ram"
model_info minicpm5-2b
test "$(model_ctx)" = 32768
test "$(PT35_IMAGE_RAM_MB=4096 model_ctx)" = 16384
if (PT35_IMAGE_RAM_MB=not-a-number ram_mb >/dev/null 2>&1); then
  echo 'invalid target RAM was accepted' >&2; exit 1
fi
printf '4096\n' > "$STATE/target-ram"

export HOME="$tmp/home"
install -d "$HOME"
cmd_agents
python3 - "$HOME/.darkwire/config.yaml" <<'PY'
import sys, yaml
cfg = yaml.safe_load(open(sys.argv[1]))
agents = cfg["agents"]["list"]
assert set(agents) == {"default", "chat", "code", "research", "lead"}
for agent in agents.values():
    assert agent["provider"] == "llamacpp"
    assert agent["model"] == "minicpm5-2b"
    assert agent["contextWindowTokens"] == 16384
assert cfg["providers"]["llamacpp"]["apiBase"] == "http://127.0.0.1:8080/v1"
assert agents["default"]["reasoningEffort"] == "off"
PY
test "$(stat -c %a "$HOME/.darkwire")" = 700
test "$(stat -c %a "$HOME/.darkwire/config.yaml")" = 600
echo 'AI image sizing and agent tests passed.'
