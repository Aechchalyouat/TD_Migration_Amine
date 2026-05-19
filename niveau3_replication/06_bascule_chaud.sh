#!/bin/bash
# niveau3_replication/06_bascule_chaud.sh
echo '=== [NIVEAU 3] Bascule a chaud ==='
echo "Debut : $(date)" | tee logs/coupure_n3.log

# 1. Verifier le lag de replication
echo '--- Lag de replication avant bascule ---'
docker exec pg_montpellier psql -U admin -d techcorp_db -c \
  "SELECT client_addr, state, sent_lsn, write_lsn, flush_lsn, replay_lsn
  FROM pg_stat_replication;"

# 2. Passer la source en lecture seule
docker exec pg_montpellier psql -U admin -d postgres -c \
  "ALTER DATABASE techcorp_db SET default_transaction_read_only = on;"
echo 'OK : Source en lecture seule'

# 3. Attendre que la replication soit complete
sleep 3

# 4. Supprimer la subscription sur la cible
docker exec pg_toulouse psql -U admin -d techcorp_db -c \
  "DROP SUBSCRIPTION sub_techcorp;"
echo 'OK : Subscription supprimee'

# 5. Activer la cible en lecture/ecriture
docker exec pg_toulouse psql -U admin -d techcorp_db -c \
  "ALTER DATABASE techcorp_db SET default_transaction_read_only = off;"
echo 'OK : Cible activee'

echo "Fin de la bascule : $(date)" | tee -a logs/coupure_n3.log
echo 'OK : Migration avec replication terminee'

# Comparaison des durees
echo ''
echo '=== Comparaison des coupures ==='
echo "N1 Big Bang      : ~4 minutes"
echo "N2 Progressive   : ~2 secondes"
echo "N3 Replication   : quelques secondes"
