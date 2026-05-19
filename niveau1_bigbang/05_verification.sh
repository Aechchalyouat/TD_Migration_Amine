#!/bin/bash
# niveau1_bigbang/05_verification.sh
echo '=== [NIVEAU 1] Verification de l integrite ==='

echo '--- Comptage SOURCE (Montpellier) ---'
docker exec pg_montpellier psql -U admin -d techcorp_db -t -c \
  "SELECT 'utilisateurs', COUNT(*) FROM utilisateurs
  UNION ALL SELECT 'formations', COUNT(*) FROM formations
  UNION ALL SELECT 'progressions', COUNT(*) FROM progressions
  UNION ALL SELECT 'resultats_examens', COUNT(*) FROM resultats_examens;"

echo '--- Comptage CIBLE (Toulouse) ---'
docker exec pg_toulouse psql -U admin -d techcorp_db -t -c \
  "SELECT 'utilisateurs', COUNT(*) FROM utilisateurs
  UNION ALL SELECT 'formations', COUNT(*) FROM formations
  UNION ALL SELECT 'progressions', COUNT(*) FROM progressions
  UNION ALL SELECT 'resultats_examens', COUNT(*) FROM resultats_examens;"

echo "Heure de fin : $(date)" | tee -a logs/coupure_debut.log

# Duree totale de coupure
DEBUT=$(grep "debut" logs/coupure_debut.log | head -1 | awk -F': ' '{print $2}')
echo "Debut coupure : $DEBUT"
echo "Fin coupure   : $(date)"

# Verification FK sur la cible
echo '--- Verification des cles etrangeres sur la cible ---'
docker exec pg_toulouse psql -U admin -d techcorp_db -c \
  "SELECT tc.table_name, kcu.column_name, ccu.table_name AS table_referencee
  FROM information_schema.table_constraints AS tc
  JOIN information_schema.key_column_usage AS kcu ON tc.constraint_name = kcu.constraint_name
  JOIN information_schema.constraint_column_usage AS ccu ON ccu.constraint_name = tc.constraint_name
  WHERE tc.constraint_type = 'FOREIGN KEY';"

