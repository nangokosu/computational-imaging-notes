#!/bin/bash
# Save current artifact as a timestamped backup
# Usage: ./save-version.sh "optional description"

BACKUP_DIR="$(dirname "$0")"
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
DESCRIPTION="${1:-auto}"
FILENAME="artifact-${TIMESTAMP}-${DESCRIPTION}.html"

if [ ! -f "/tmp/index.html" ]; then
    echo "✗ ERROR: /tmp/index.html not found"
    echo "  Run Artifact tool read first: Artifact(action:read, url:...)"
    exit 1
fi

SIZE=$(du -h /tmp/index.html | cut -f1)
cp /tmp/index.html "$BACKUP_DIR/$FILENAME"

echo "✓ Saved backup: $FILENAME ($SIZE)"
echo "  Path: $BACKUP_DIR/$FILENAME"

# Verify it's a good backup
if grep -q 'id="week-5"' "$BACKUP_DIR/$FILENAME"; then
    echo "✓ Verified: Contains all 5 weeks"
    cp "$BACKUP_DIR/$FILENAME" "$BACKUP_DIR/artifact-latest-good.html"
    echo "✓ Updated artifact-latest-good.html"
else
    echo "⚠ WARNING: Backup may be incomplete"
fi

# Show recent backups
echo ""
echo "Recent backups:"
ls -1t "$BACKUP_DIR"/artifact-*.html | head -5 | xargs -I {} basename {}
