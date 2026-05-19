#!/bin/bash
# niveau1_bigbang/01_arret_source.sh
echo '=== [NIVEAU 1] Arret du service source ==='
echo "Heure de debut de coupure : $(date)" | tee logs/coupure_debut.log

# Passer la base en lecture seule
docker exec pg_montpellier psql -U admin -d techcorp_db -c \
  "ALTER DATABASE techcorp_db SET default_transaction_read_only = on;"

echo 'OK : Base source passee en lecture seule'

# Verification qu'aucune transaction n'est en cours
docker exec pg_montpellier psql -U admin -d techcorp_db -c \
  "SELECT pid, state, query FROM pg_stat_activity WHERE state = 'active';"
