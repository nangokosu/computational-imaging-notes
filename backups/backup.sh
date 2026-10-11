#!/bin/bash
# Frequent artifact backup script
# Add to crontab with: 0 */4 * * * /path/to/backup.sh  (every 4 hours)
# Or for more frequent: */30 * * * * /path/to/backup.sh (every 30 minutes)

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

# Retention policy: keep last 30 backups, delete anything older than 90 days
echo "[$(date)] Cleaning up old backups (keep 30 most recent, delete >90 days)..."
# Delete backups older than 90 days
find "$BACKUP_DIR" -name "artifact-[0-9]*.html" -mtime +90 -delete

# Keep only 30 most recent backups (in case cron runs very frequently)
BACKUP_COUNT=$(find "$BACKUP_DIR" -name "artifact-[0-9]*.html" | wc -l)
if [ "$BACKUP_COUNT" -gt 30 ]; then
    EXCESS=$((BACKUP_COUNT - 30))
    find "$BACKUP_DIR" -name "artifact-[0-9]*.html" -printf '%T@ %p\n' | sort -n | head -n "$EXCESS" | cut -d' ' -f2- | xargs rm
    echo "[$(date)] Cleaned up $EXCESS old backups"
fi
echo "[$(date)] Done ($(find "$BACKUP_DIR" -name "artifact-[0-9]*.html" | wc -l) backups retained)"
