#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

# ---------------------------------------------------------------------------
# install.sh – pull the C# style-guide files next to a given .sln/.slnx file
#
# Usage:
#   ./install.sh <path-to-solution-file>    # explicit .sln/.slnx
#   ./install.sh <directory>          # auto-detect sln in that dir
#   ./install.sh                # auto-detect sln in $PWD
# ---------------------------------------------------------------------------

REPO_RAW="https://raw.githubusercontent.com/frederik-hoeft/csharp-syle-guide/refs/heads/main"

# Files to download as-is (destination name == source name)
PLAIN_FILES=(
  ".editorconfig"
  "Directory.Build.props"
)

# Files to download with a renamed destination: "source:destination"
RENAMED_FILES=(
  "README.md:code-style.md"
)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

die() { printf 'error: %s\n' "$*" >&2; exit 1; }

require_cmd() {
  command -v "$1" &>/dev/null || die "'$1' is required but not installed."
}

# ---------------------------------------------------------------------------
# Resolve the solution directory
# ---------------------------------------------------------------------------

resolve_sln_dir() {
  local arg="${1:-}"

  if [[ -z "$arg" ]]; then
    # No argument: search current directory
    arg="$PWD"
  fi

  if [[ -f "$arg" ]]; then
    # Argument is a file – validate extension
    case "$arg" in
      *.sln|*.slnx) ;;
      *) die "'$arg' is not a .sln or .slnx file." ;;
    esac
    dirname "$(realpath -- "$arg")"
    return
  fi

  if [[ -d "$arg" ]]; then
    # Argument is a directory – auto-detect a single sln/slnx inside it
    local dir
    dir="$(realpath -- "$arg")"
    local -a slns=("$dir"/*.sln "$dir"/*.slnx)
    case "${#slns[@]}" in
      0) die "No .sln or .slnx file found in '$dir'." ;;
      1) printf '%s' "$dir" ;;
      *) die "Multiple solution files found in '$dir'; please specify one explicitly." ;;
    esac
    return
  fi

  die "'$arg' is not a file or directory."
}

# ---------------------------------------------------------------------------
# Download a single file
# ---------------------------------------------------------------------------

download() {
  local src_name="$1"
  local dst_path="$2"

  printf '  %-30s -> %s\n' "$src_name" "$dst_path"

  if command -v wget &>/dev/null; then
    wget --quiet --output-document="$dst_path" \
       "${REPO_RAW}/${src_name}"
  elif command -v curl &>/dev/null; then
    curl --silent --show-error --fail --location \
       --output "$dst_path" \
       "${REPO_RAW}/${src_name}"
  else
    die "Neither 'wget' nor 'curl' is available."
  fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {
  local sln_dir
  sln_dir="$(resolve_sln_dir "${1:-}")"

  printf 'Installing C# style-guide files into: %s\n' "$sln_dir"

  for name in "${PLAIN_FILES[@]}"; do
    download "$name" "$sln_dir/$name"
  done

  for entry in "${RENAMED_FILES[@]}"; do
    local src="${entry%%:*}"
    local dst="${entry##*:}"
    download "$src" "$sln_dir/$dst"
  done

  printf 'Done.\n'
}

main "$@"
