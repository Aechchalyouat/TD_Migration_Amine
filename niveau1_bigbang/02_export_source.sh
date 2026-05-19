#!/bin/bash
# niveau1_bigbang/02_export_source.sh
echo '=== [NIVEAU 1] Export de la base source ==='
BACKUP_DIR='./backups'
BACKUP_FILE="$BACKUP_DIR/techcorp_bigbang_$(date +%Y%m%d_%H%M%S).dump"
mkdir -p $BACKUP_DIR

# Export complet en format custom
docker exec pg_montpellier pg_dump \
  -U admin -d techcorp_db \
  -F c -v \
  -f /tmp/techcorp_backup.dump

# Copier le fichier hors du container
docker cp pg_montpellier:/tmp/techcorp_backup.dump $BACKUP_FILE

echo "OK : Sauvegarde creee : $BACKUP_FILE"
ls -lh $BACKUP_FILE

# Verification que le fichier n'est pas vide
[ -s $BACKUP_FILE ] && echo 'OK : fichier non vide' || echo 'ERREUR : fichier vide'
