#!/bin/bash
# niveau2_progressive/01_sync_initiale.sh
echo '=== [NIVEAU 2] Synchronisation initiale (hors coupure) ==='
echo "Debut : $(date)"

BACKUP_DIR='./backups'
mkdir -p $BACKUP_DIR

# Export de la base source en format SQL plain
docker exec pg_montpellier pg_dump \
  -U admin -d techcorp_db \
  --format=plain --no-owner --no-acl \
  -f /tmp/sync_initiale.sql

docker cp pg_montpellier:/tmp/sync_initiale.sql $BACKUP_DIR/sync_initiale.sql

# Restaurer sur la cible (vider d'abord)
docker exec pg_toulouse psql -U admin -d techcorp_db -c \
  "DROP TABLE IF EXISTS progressions, resultats_examens, utilisateurs, formations CASCADE;"

docker cp $BACKUP_DIR/sync_initiale.sql pg_toulouse:/tmp/sync_initiale.sql
docker exec pg_toulouse psql -U admin -d techcorp_db -f /tmp/sync_initiale.sql

# Synchronisation des fichiers
rsync -avh --progress \
  ./data_montpellier/supports/ \
  ./data_toulouse/supports/

echo "OK : Synchronisation initiale terminee : $(date)"

# Checksum de l'etat de la base
docker exec pg_montpellier psql -U admin -d techcorp_db -t -c \
  "SELECT COUNT(*) FROM utilisateurs;" > ./backups/checksum_sync_initiale.txt
echo "Checksum enregistre : $(cat ./backups/checksum_sync_initiale.txt)"
