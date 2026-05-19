#!/bin/bash
# niveau3_replication/04_subscription.sh
echo '=== [NIVEAU 3] Creation de la SUBSCRIPTION sur la cible ==='

# Recuperer l'IP du container source
SOURCE_IP=$(docker inspect pg_montpellier \
  --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
echo "IP du container source : $SOURCE_IP"

# Creer la subscription sur la cible
docker exec pg_toulouse psql -U admin -d techcorp_db -c \
  "CREATE SUBSCRIPTION sub_techcorp
  CONNECTION 'host=$SOURCE_IP port=5432 dbname=techcorp_db user=admin password=admin123'
  PUBLICATION pub_techcorp;"

echo 'OK : Subscription creee – replication en cours...'
sleep 5

# Verifier l'etat de la replication
docker exec pg_toulouse psql -U admin -d techcorp_db -c \
  "SELECT subname, subenabled FROM pg_subscription;"

# Verifier que les donnees sont arrivees
docker exec pg_toulouse psql -U admin -d techcorp_db -c \
  'SELECT COUNT(*) AS nb_utilisateurs FROM utilisateurs;'

# Etat detaille
docker exec pg_montpellier psql -U admin -d techcorp_db -c \
  "SELECT * FROM pg_stat_replication;"
