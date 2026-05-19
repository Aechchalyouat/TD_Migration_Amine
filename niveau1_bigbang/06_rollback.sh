#!/bin/bash
# niveau1_bigbang/06_rollback.sh
echo '=== [NIVEAU 1] ROLLBACK – Retour a Montpellier ==='
echo 'ATTENTION : Cette operation annule la migration !'
read -p 'Confirmer le rollback ? (oui/non) : ' CONFIRM

if [ "$CONFIRM" != 'oui' ]; then
  echo 'Rollback annule.'
  exit 0
fi

# Remettre la source en lecture/ecriture
docker exec pg_montpellier psql -U admin -d techcorp_db -c \
  "ALTER DATABASE techcorp_db SET default_transaction_read_only = off;"
echo 'OK : Base source remise en lecture/ecriture'

# Vider la base cible pour eviter toute confusion
docker exec pg_toulouse psql -U admin -d techcorp_db -c \
  "DROP TABLE IF EXISTS progressions, resultats_examens, utilisateurs, formations CASCADE;"
echo 'OK : Base cible videe'

# Logger la raison du rollback
echo "$(date) - Rollback N1 effectue" >> logs/rollback.log
echo 'OK : Rollback termine, service reprend sur Montpellier'
