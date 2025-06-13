#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

# Get list of rulesets from bazel mod deps
rulesets=$(bazel mod deps doc.bzl --depth=1 --output=json | jq -r '.dependencies[].apparentName')

for ruleset in $rulesets; do
    echo "Processing $ruleset..."

# Get public bzl_library targets
# Get all targets first
labels=$(bazel 2>/dev/null query --output=label --keep_going \
    "kind(\"bzl_library rule\", @${ruleset}//...)" | \
    grep -v '/private' | grep -v '/tests' \
    || true)

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
done

echo "All rulesets processed successfully"