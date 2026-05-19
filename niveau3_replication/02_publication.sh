#!/bin/bash
# niveau3_replication/02_publication.sh
echo '=== [NIVEAU 3] Creation de la PUBLICATION sur la source ==='

# Creer une publication pour toutes les tables
docker exec pg_montpellier psql -U admin -d techcorp_db -c \
  "CREATE PUBLICATION pub_techcorp FOR ALL TABLES;"

# Verifier que la publication est creee
docker exec pg_montpellier psql -U admin -d techcorp_db -c \
  "SELECT pubname, puballtables FROM pg_publication;"

echo 'OK : Publication creee sur la source'

# Afficher les tables publiees
docker exec pg_montpellier psql -U admin -d techcorp_db -c \
  "SELECT * FROM pg_publication_tables;"
