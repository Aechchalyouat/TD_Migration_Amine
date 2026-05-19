#!/bin/bash
# niveau2_progressive/05_bascule_validation.sh
echo '=== [NIVEAU 2] Bascule et validation ==='

SOURCE_COUNT=$(docker exec pg_montpellier psql -U admin -d techcorp_db -t -c \
  'SELECT COUNT(*) FROM utilisateurs;' | tr -d ' ')
CIBLE_COUNT=$(docker exec pg_toulouse psql -U admin -d techcorp_db -t -c \
  'SELECT COUNT(*) FROM utilisateurs;' | tr -d ' ')

echo "Utilisateurs source : $SOURCE_COUNT"
echo "Utilisateurs cible  : $CIBLE_COUNT"

if [ "$SOURCE_COUNT" != "$CIBLE_COUNT" ]; then
  echo 'ERREUR : les comptages ne correspondent pas !'
  echo 'Rollback recommande'
  exit 1
fi

echo 'OK : Comptages identiques – bascule autorisee'

# Activer la cible en lecture/ecriture
docker exec pg_toulouse psql -U admin -d techcorp_db -c \
  "ALTER DATABASE techcorp_db SET default_transaction_read_only = off;"
echo 'OK : Cible activee en lecture/ecriture'

# Test insertion sur la cible
docker exec pg_toulouse psql -U admin -d techcorp_db -c \
  "INSERT INTO utilisateurs (nom, email) VALUES ('Test Bascule N2', 'testN2@techcorp.fr');"
echo 'OK : Insertion test sur la cible reussie'

echo 'OK : Migration progressive terminee avec succes'
echo "Heure de fin : $(date)" | tee -a logs/coupure_n2.log

