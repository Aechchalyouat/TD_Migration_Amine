#!/bin/bash
# niveau3_replication/05_test_replication.sh
echo '=== [NIVEAU 3] Test de la replication en temps reel ==='

echo '--- Avant insertion ---'
echo -n 'Source : '
docker exec pg_montpellier psql -U admin -d techcorp_db -t -c \
  'SELECT COUNT(*) FROM utilisateurs;'
echo -n 'Cible  : '
docker exec pg_toulouse psql -U admin -d techcorp_db -t -c \
  'SELECT COUNT(*) FROM utilisateurs;'

# Inserer un nouvel utilisateur sur la SOURCE
docker exec pg_montpellier psql -U admin -d techcorp_db -c \
  "INSERT INTO utilisateurs (nom, email)
  VALUES ('Test Replication', 'test.replication@techcorp.fr');"

sleep 2

echo '--- Apres insertion (2 secondes plus tard) ---'
echo -n 'Source : '
docker exec pg_montpellier psql -U admin -d techcorp_db -t -c \
  'SELECT COUNT(*) FROM utilisateurs;'
echo -n 'Cible  : '
docker exec pg_toulouse psql -U admin -d techcorp_db -t -c \
  'SELECT COUNT(*) FROM utilisateurs;'

echo 'Si les deux comptages sont identiques, la replication fonctionne !'

# Mesurer le lag de replication
echo '--- Lag de replication ---'
docker exec pg_montpellier psql -U admin -d techcorp_db -c \
  "SELECT application_name, state, sync_state,
   write_lag, flush_lag, replay_lag
   FROM pg_stat_replication;"
