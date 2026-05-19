#!/bin/bash
# niveau3_replication/07_nettoyage.sh
echo '=== [NIVEAU 3] Nettoyage post-migration ==='

# Supprimer la publication sur la source
docker exec pg_montpellier psql -U admin -d techcorp_db -c \
  "DROP PUBLICATION IF EXISTS pub_techcorp;"
echo 'OK : Publication supprimee sur la source'

# Verification finale
echo '--- Etat final de la cible ---'
docker exec pg_toulouse psql -U admin -d techcorp_db -c \
  "SELECT 'utilisateurs', COUNT(*) FROM utilisateurs
  UNION ALL SELECT 'formations', COUNT(*) FROM formations
  UNION ALL SELECT 'progressions', COUNT(*) FROM progressions
  UNION ALL SELECT 'resultats_examens', COUNT(*) FROM resultats_examens;"
