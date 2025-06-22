#!/bin/bash
# Local backup
BACKUP_FILE="backups/keycloak-$(date +%Y-%m-%d).sql.gz"
docker-compose exec -T postgres pg_dump -U keycloak keycloak | gzip > $BACKUP_FILE

# Cloud backup (Rclone to Google Drive)
# rclone copy $BACKUP_FILE gdrive:/keycloak-backups/

# Cleanup
find backups/ -name "*.sql.gz" -mtime +7 -delete