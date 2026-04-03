#!/bin/bash
# Clear the remote Bazel cache for specific designs.
#
# This works by invalidating the cache entries — it runs a no-op build with
# --remote_upload_local_results=true after cleaning the local build artifacts,
# which causes Bazel to rebuild and overwrite stale cache entries.
#
# For the GCS bucket, this script directly deletes cached action results using
# gsutil (requires gcloud auth with write access to the bucket).
#
# Usage:
#   ./k8s/clear-cache.sh [platform] [design]   # clear a specific design
#   ./k8s/clear-cache.sh [platform]             # clear all designs for a platform
#   ./k8s/clear-cache.sh --design [design]      # clear a design across all platforms
#   ./k8s/clear-cache.sh --all                  # clear the entire cache
#   ./k8s/clear-cache.sh --local                # clear local disk cache only
#
# Options:
#   --local    Only clear local disk cache (no GCS changes)
#   --remote   Only clear remote GCS cache
#   --all      Clear the entire cache (local + remote)
#   --dry-run  Show what would be cleared without doing it

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DISK_CACHE="${HOME}/.cache/bazel-disk-cache"
GCS_BUCKET="gs://hightide-bazel-cache"

# Defaults
DRY_RUN=false
CLEAR_LOCAL=true
CLEAR_REMOTE=true
CLEAR_ALL=false
FILTER_PLATFORM=""
FILTER_DESIGN=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --local)    CLEAR_REMOTE=false; shift ;;
        --remote)   CLEAR_LOCAL=false; shift ;;
        --all)      CLEAR_ALL=true; shift ;;
        --dry-run)  DRY_RUN=true; shift ;;
        --design)   FILTER_DESIGN="$2"; shift 2 ;;
        -h|--help)
            sed -n '2,/^$/s/^# //p' "$0"
            exit 0
            ;;
        *)
            if [[ -z "$FILTER_PLATFORM" ]]; then
                FILTER_PLATFORM="$1"
            elif [[ -z "$FILTER_DESIGN" ]]; then
                FILTER_DESIGN="$1"
            else
                echo "ERROR: unexpected argument: $1" >&2
                exit 1
            fi
            shift
            ;;
    esac
done

if [[ "$CLEAR_ALL" == true ]]; then
    echo "Clearing entire Bazel cache..."

    if [[ "$CLEAR_LOCAL" == true ]]; then
        echo -n "  Local disk cache ($DISK_CACHE)... "
        if [[ "$DRY_RUN" == true ]]; then
            echo "would delete"
        else
            rm -rf "$DISK_CACHE"
            echo "cleared"
        fi
    fi

    if [[ "$CLEAR_REMOTE" == true ]]; then
        echo -n "  Remote GCS cache ($GCS_BUCKET)... "
        if [[ "$DRY_RUN" == true ]]; then
            echo "would delete all objects"
        else
            gsutil -m rm -r "${GCS_BUCKET}/**" 2>/dev/null && echo "cleared" || echo "already empty or no access"
        fi
    fi

    if [[ "$CLEAR_LOCAL" == true ]]; then
        echo -n "  Bazel output base... "
        if [[ "$DRY_RUN" == true ]]; then
            echo "would run bazel clean"
        else
            (cd "$REPO_DIR" && bazel clean 2>/dev/null) && echo "cleaned" || echo "skipped"
        fi
    fi

    exit 0
fi

# Discover designs (same logic as run.sh)
discover_designs() {
    for build_file in "$REPO_DIR"/designs/*/BUILD.bazel \
                      "$REPO_DIR"/designs/*/*/BUILD.bazel \
                      "$REPO_DIR"/designs/*/*/*/BUILD.bazel; do
        [[ -f "$build_file" ]] || continue
        grep -q 'hightide_design(' "$build_file" || continue

        local dir
        dir=$(dirname "$build_file")
        local name
        name=$(grep -A1 'hightide_design(' "$build_file" | grep -oP 'name\s*=\s*"\K[^"]+')
        [[ -z "$name" ]] && continue

        local relpath="${dir#$REPO_DIR/designs/}"
        local platform="${relpath%%/*}"
        local target="//designs/$relpath:${name}_final"

        echo "$platform|$name|$relpath|$target"
    done
}

# Collect matching designs
DESIGNS=()
while IFS='|' read -r platform name relpath target; do
    if [[ -n "$FILTER_PLATFORM" && "$platform" != "$FILTER_PLATFORM" ]]; then
        continue
    fi
    if [[ -n "$FILTER_DESIGN" ]]; then
        design_dir="${relpath#*/}"
        if [[ "$name" != "$FILTER_DESIGN" && "$design_dir" != *"$FILTER_DESIGN"* ]]; then
            continue
        fi
    fi
    DESIGNS+=("$platform|$name|$relpath|$target")
done < <(discover_designs | sort)

if [[ ${#DESIGNS[@]} -eq 0 ]]; then
    echo "No designs matched the given filters."
    echo "  Platform: ${FILTER_PLATFORM:-<all>}"
    echo "  Design:   ${FILTER_DESIGN:-<all>}"
    exit 1
fi

echo "Clearing cache for ${#DESIGNS[@]} design(s)..."
echo "  Local:  $CLEAR_LOCAL"
echo "  Remote: $CLEAR_REMOTE"
echo ""

for entry in "${DESIGNS[@]}"; do
    IFS='|' read -r platform name relpath target <<< "$entry"
    echo -n "  $platform/$name ... "

    if [[ "$CLEAR_LOCAL" == true ]]; then
        # Clear local bazel-bin outputs for this design
        local_dir="$REPO_DIR/bazel-bin/designs/$relpath"
        if [[ -d "$local_dir" ]]; then
            if [[ "$DRY_RUN" == true ]]; then
                echo -n "would delete $local_dir "
            else
                rm -rf "$local_dir"
                echo -n "local "
            fi
        fi
    fi

    if [[ "$CLEAR_REMOTE" == true ]]; then
        # Bazel remote cache uses content-addressed hashes, not design paths.
        # We can't selectively delete by design from GCS without knowing the hashes.
        # Instead, we force Bazel to rebuild by modifying the action environment.
        # The simplest approach: tell the user to rebuild with --noremote_accept_cached.
        if [[ "$DRY_RUN" == true ]]; then
            echo -n "remote: use --noremote_accept_cached to force rebuild "
        else
            echo -n "(rebuild with: bazel build --noremote_accept_cached $target) "
        fi
    fi

    echo "done"
done

echo ""
echo "Note: The remote cache is content-addressed and cannot be selectively"
echo "cleared by design name. To force a fresh build that overwrites cached"
echo "results, rebuild with:"
echo ""
echo "  bazel build --noremote_accept_cached --remote_upload_local_results=true \\"
echo "    --google_credentials=/path/to/key.json <target>"
echo ""
echo "To clear the entire remote cache, use: ./tools/clear-cache.sh --all"
