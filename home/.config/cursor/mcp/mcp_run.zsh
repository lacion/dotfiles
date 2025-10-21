#!/usr/bin/env zsh
# Resolves 1Password secret refs in env (op://...), expands $VARS in args, then execs the command.

set -euo pipefail

# --- Config via env ---
# MCP_SECRET_VARS: optional comma/space/colon-separated list of env var names to resolve via 1Password
# MCP_RUN_DEBUG=1: minimal debug logging (variable names only; never values)

debug() {
  [[ -n "${MCP_RUN_DEBUG:-}" ]] && print -u2 -- "[mcp_run] $*"
}

die() {
  print -u2 -- "Error: $*"
  exit 1
}

# Expand $VAR and ${VAR} using current environment (envsubst if present, else perl fallback)
expand_arg() {
  local input="$1" out=""
  if command -v envsubst >/dev/null 2>&1; then
    out="$(print -r -- "$input" | envsubst)"
  else
    # Expand ${VAR} then $VAR; only [A-Za-z_][A-Za-z0-9_] names
    out="$(perl -pe 's/\$\{([A-Za-z_][A-Za-z0-9_]*)\}/$ENV{$1}//ge; s/\$([A-Za-z_][A-Za-z0-9_]*)/$ENV{$1}//ge' <<< "$input")"
  fi
  print -r -- "$out"
}

# Collect env vars that contain op:// secret references
collect_secret_vars() {
  local -a secrets=()

  if [[ -n "${MCP_SECRET_VARS:-}" ]]; then
    # Split by comma/space/colon/newline
    while IFS= read -r var; do
      [[ -z "$var" ]] && continue
      [[ "$var" == [A-Za-z_][A-Za-z0-9_]* ]] || continue
      secrets+=("$var")
    done < <(print -r -- "$MCP_SECRET_VARS" | tr ',: ' '\n\n\n' | sed '/^[[:space:]]*$/d')
  else
    # Auto-detect any env value starting with op://
    while IFS= read -r line; do
      [[ "$line" == *"="* ]] || continue
      local name="${line%%=*}"
      local val="${line#*=}"
      if [[ "$val" == op://* ]]; then
        secrets+=("$name")
      fi
    done < <(env)
  fi

  print -l -- "${secrets[@]}"
}

resolve_secrets() {
  local -a secrets=("$@")
  (( ${#secrets[@]} == 0 )) && return 0

  command -v op >/dev/null 2>&1 || die "1Password CLI 'op' not found but secret references are present: ${secrets[*]}"

  for name in "${secrets[@]}"; do
    local ref
    ref="$(printenv "$name" 2>/dev/null || true)"
    [[ "$ref" == op://* ]] || continue
    debug "Resolving secret: $name"
    # Read secret; keep internal newlines, trim a single trailing newline if present
    local value
    if ! value="$(op read "$ref" 2>/dev/null)"; then
      die "Failed to resolve secret for '$name' via '$ref'. Are you signed in (op signin)?"
    fi
    # Trim one trailing newline typical from op read
    [[ "${value[-1]}" == $'\n' ]] && value="${value%$'\n'}"
    export "${name}=${value}"
  done
}

main() {
  if (( $# == 0 )); then
    die "Usage: mcp_run.zsh <command> [args...]
Example:
  mcp_run.zsh npx -y mcp-remote https://mcp.linear.app/sse
With a 1Password secret in env:
  CONTEXT7_API_KEY=op://development/'Context7 Token'/credential \\
  mcp_run.zsh npx -y @upstash/context7-mcp --api-key \${CONTEXT7_API_KEY}"
  fi

  # 1) Resolve any op:// secrets in the environment
  local -a secret_names
  secret_names=($(collect_secret_vars))
  resolve_secrets "${secret_names[@]}"

  # 2) Expand $VARS in args (after secrets are resolved)
  local -a expanded_args
  expanded_args=()
  for arg in "$@"; do
    expanded_args+=("$(expand_arg "$arg")")
  done

  # 3) Exec the target command
  debug "Executing: ${expanded_args[1]} [args redacted]"
  exec "${expanded_args[@]}"
}

main "$@"