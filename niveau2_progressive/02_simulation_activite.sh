#!/bin/bash
# niveau2_progressive/02_simulation_activite.sh
echo '=== [NIVEAU 2] Simulation d activite utilisateur ==='

# Ajouter de nouveaux utilisateurs
docker exec pg_montpellier psql -U admin -d techcorp_db -c \
  "INSERT INTO utilisateurs (nom, email) VALUES
  ('Francois Petit', 'francois@techcorp.fr'),
  ('Gaelle Simon', 'gaelle@techcorp.fr');"

# Mettre a jour une progression
docker exec pg_montpellier psql -U admin -d techcorp_db -c \
  "UPDATE progressions SET pourcentage = 100, derniere_activite = NOW()
  WHERE utilisateur_id = 1 AND formation_id = 2;"

# Ajouter un resultat d'examen
docker exec pg_montpellier psql -U admin -d techcorp_db -c \
  "INSERT INTO resultats_examens (utilisateur_id, formation_id, note)
  VALUES (3, 1, 16.5);"

# Ajouter un nouveau fichier support
echo 'Nouveau support Python debutants' > data_montpellier/supports/python_intro.pdf

echo 'OK : Nouvelles donnees ajoutees sur la source'
echo '  2 nouveaux utilisateurs, 1 progression mise a jour'
echo '  1 nouveau resultat examen, 1 nouveau fichier support'

# Verification
docker exec pg_montpellier psql -U admin -d techcorp_db -c \
  "SELECT COUNT(*) AS nb_utilisateurs FROM utilisateurs;"

