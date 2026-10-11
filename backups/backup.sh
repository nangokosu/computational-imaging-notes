#!/bin/bash
# Weekly artifact backup script
# Add to crontab with: 0 2 * * 0 /path/to/backup.sh

set -e

BACKUP_DIR="/Users/khainguyen/Projects/computational-imaging-notes/backups"
ARTIFACT_URL="https://claude.ai/artifact/4pG6rjMnLYwEzVmncvNH1r"
FILENAME="artifact-$(date +%Y-%m-%d).html"

echo "[$(date)] Backing up artifact..."

# Download the artifact
curl -s "$ARTIFACT_URL" > "$BACKUP_DIR/$FILENAME"

if [ -s "$BACKUP_DIR/$FILENAME" ]; then
    echo "[$(date)] Backup saved to $FILENAME ($(du -h "$BACKUP_DIR/$FILENAME" | cut -f1))"

    # Verify it has content (check for week-1 at minimum)
    if grep -q 'id="week-1"' "$BACKUP_DIR/$FILENAME"; then
        echo "[$(date)] ✓ Backup verified (contains week-1)"

        # Update latest-good if this one looks complete
        if grep -q 'id="week-5"' "$BACKUP_DIR/$FILENAME"; then
            cp "$BACKUP_DIR/$FILENAME" "$BACKUP_DIR/artifact-latest-good.html"
            echo "[$(date)] ✓ Updated artifact-latest-good.html"
        fi
    else
        echo "[$(date)] ✗ WARNING: Backup may be incomplete or corrupted"
        rm "$BACKUP_DIR/$FILENAME"
        exit 1
    fi
else
    echo "[$(date)] ✗ ERROR: Failed to download artifact"
    exit 1
fi

# Clean up backups older than 28 days
echo "[$(date)] Cleaning up old backups..."
find "$BACKUP_DIR" -name "artifact-[0-9]*.html" -mtime +28 -exec rm {} \;
echo "[$(date)] Done"
