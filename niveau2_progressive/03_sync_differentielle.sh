#!/bin/bash
# niveau2_progressive/03_sync_differentielle.sh
echo '=== [NIVEAU 2] Synchronisation differentielle ==='

# Fichiers : rsync ne retransfere que les nouveaux/modifies
rsync -avh --progress --checksum \
  ./data_montpellier/supports/ \
  ./data_toulouse/supports/

# Base : export des donnees recentes
docker exec pg_montpellier pg_dump \
  -U admin -d techcorp_db \
  --format=plain --data-only \
  -f /tmp/sync_diff.sql

docker cp pg_montpellier:/tmp/sync_diff.sql ./backups/sync_diff.sql

echo 'OK : Synchronisation differentielle terminee'

# Comparer le nombre de lignes entre source et cible
echo '--- Comparaison source vs cible ---'
echo -n 'Source utilisateurs : '
docker exec pg_montpellier psql -U admin -d techcorp_db -t -c 'SELECT COUNT(*) FROM utilisateurs;'
echo -n 'Cible utilisateurs  : '
docker exec pg_toulouse psql -U admin -d techcorp_db -t -c 'SELECT COUNT(*) FROM utilisateurs;'
