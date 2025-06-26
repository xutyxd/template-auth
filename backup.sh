#!/bin/bash
# Local backup
BACKUP_DIR="./backups"
cp ./data/casdoor.db "$BACKUP_DIR/casdoor_$(date +%Y%m%d).db"
find "$BACKUP_DIR" -name "*.db" -mtime +7 -delete

# Cleanup
find backups/ -name "*.sql.gz" -mtime +7 -delete