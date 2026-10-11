#!/bin/bash
# Automatic backup after artifact changes
# Called by Claude Code after every artifact publish
# Usage: ./auto-backup.sh "commit-message-from-change"

set -e

BACKUP_DIR="$(dirname "$0")"
cd "$BACKUP_DIR/../"

TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
CHANGE_DESC="$1"

# If no description provided, use timestamp only
if [ -z "$CHANGE_DESC" ]; then
    CHANGE_DESC="auto"
fi

# Sanitize description for filename
SAFE_DESC=$(echo "$CHANGE_DESC" | tr ' ' '-' | sed 's/[^a-zA-Z0-9_-]//g' | cut -c1-50)

BACKUP_FILE="backups/artifact-${TIMESTAMP}-${SAFE_DESC}.html"

# Read current artifact
echo "[$(date)] Reading artifact..."
if [ ! -f "/tmp/index.html" ]; then
    echo "✗ ERROR: /tmp/index.html not found - artifact not published yet"
    exit 1
fi

# Copy to versioned backup
cp /tmp/index.html "$BACKUP_FILE"
SIZE=$(du -h "$BACKUP_FILE" | cut -f1)

echo "✓ Backup saved: $BACKUP_FILE ($SIZE)"

# Verify it's good (contains week-5)
if grep -q 'id="week-5"' "$BACKUP_FILE"; then
    echo "✓ Verified: Contains all 5 weeks"

    # Update latest-good
    cp "$BACKUP_FILE" "backups/artifact-latest-good.html"

    # Auto-commit backup
    echo "[$(date)] Committing backup..."
    git add "backups/artifact-latest-good.html"
    git commit -m "Auto-backup: artifact after $CHANGE_DESC" || true
    git push origin main || true

    echo "✓ Committed to git"
else
    echo "⚠ WARNING: Backup may be incomplete (missing week-5)"
    exit 1
fi

echo "[$(date)] Backup complete"
