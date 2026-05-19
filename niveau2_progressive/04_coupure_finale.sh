#!/bin/bash
# niveau2_progressive/04_coupure_finale.sh
echo '=== [NIVEAU 2] COUPURE – Synchronisation finale ==='
echo "Debut de la fenetre de coupure : $(date)" | tee logs/coupure_n2.log

# 1. Passer la source en lecture seule
docker exec pg_montpellier psql -U admin -d postgres -c \
  "ALTER DATABASE techcorp_db SET default_transaction_read_only = on;"
echo 'OK : Source en lecture seule'

# 2. Derniere synchronisation des fichiers
rsync -avh --checksum --delete \
  ./data_montpellier/supports/ \
  ./data_toulouse/supports/
echo 'OK : Fichiers synchronises'

# 3. Dernier export de la base
docker exec pg_montpellier pg_dump \
  -U admin -d techcorp_db \
  --format=custom -f /tmp/sync_finale.dump
docker cp pg_montpellier:/tmp/sync_finale.dump ./backups/sync_finale.dump
echo 'OK : Export final cree'

# 4. Restauration finale sur la cible
docker exec pg_toulouse psql -U admin -d techcorp_db -c \
  "DROP TABLE IF EXISTS progressions, resultats_examens, utilisateurs, formations CASCADE;"
docker cp ./backups/sync_finale.dump pg_toulouse:/tmp/sync_finale.dump
docker exec pg_toulouse pg_restore \
  -U admin -d techcorp_db \
  --clean --if-exists -v \
  /tmp/sync_finale.dump
echo 'OK : Restauration finale terminee'

echo "Fin de la synchronisation finale : $(date)" | tee -a logs/coupure_n2.log

# Duree de coupure
DEBUT=$(grep "Debut" logs/coupure_n2.log | awk -F': ' '{print $2}')
echo "Debut : $DEBUT"
echo "Fin   : $(date)"
