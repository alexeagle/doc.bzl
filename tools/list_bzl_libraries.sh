#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

if [ $# -ne 1 ]; then
    echo "Error: Please provide a ruleset argument"
    echo "Usage: $0 <ruleset>"
    exit 1
fi

ruleset=$1

# Get public bzl_library targets
labels=$(bazel 2>/dev/null query --output=label --keep_going \
    "kind(\"bzl_library rule\", @${ruleset}//...)" | \
    grep -v '/private' | grep -v '/tests' \
    || true
)

# Strip prefix and convert to JSON array
json_labels=$(printf '%s\n' "$labels" | sed 's|@'"$ruleset"'//||' | jq -R . | jq -s .)

# Update rules.json
FILTER=$(mktemp)
cat >$FILTER <<'EOF'
if .modules == null then {modules: []} else . end |
.modules = ([.modules[] | select(.name != $ruleset)] + [{name: $ruleset, bzl_library_targets: $targets}] | sort_by(.name))
EOF

echo "Updating rules.json..."
if ! jq --arg ruleset "$ruleset" --argjson targets "$json_labels" --from-file $FILTER rules.json > rules.json.tmp; then
    echo "Error: Failed to update rules.json"
    rm -f rules.json.tmp
    exit 1
fi

if ! mv rules.json.tmp rules.json; then
    echo "Error: Failed to save rules.json"
    rm -f rules.json.tmp
    exit 1
fi

echo "Successfully updated rules.json"