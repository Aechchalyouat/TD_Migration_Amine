#!/bin/bash
# niveau1_bigbang/03_transfert_fichiers.sh
echo '=== [NIVEAU 1] Transfert des fichiers ==='
SOURCE='./data_montpellier/supports/'
CIBLE='./data_toulouse/supports/'

rsync -avh --progress --checksum $SOURCE $CIBLE

echo ''
echo '=== Verification du transfert ==='
NB_SOURCE=$(find $SOURCE -type f | wc -l)
NB_CIBLE=$(find $CIBLE -type f | wc -l)
echo "Fichiers source : $NB_SOURCE"
echo "Fichiers cible : $NB_CIBLE"

if [ $NB_SOURCE -eq $NB_CIBLE ]; then
  echo 'OK : meme nombre de fichiers'
else
  echo 'ERREUR : nombre de fichiers different !'
  exit 1
fi

# Verification par checksums MD5
md5sum data_montpellier/supports/* > /tmp/checksums_source.txt
md5sum data_toulouse/supports/* > /tmp/checksums_cible.txt
# Comparer uniquement les hashs (pas les chemins)
awk '{print $1}' /tmp/checksums_source.txt | sort > /tmp/hash_source.txt
awk '{print $1}' /tmp/checksums_cible.txt | sort > /tmp/hash_cible.txt
diff /tmp/hash_source.txt /tmp/hash_cible.txt && echo 'OK : checksums identiques' || echo 'ERREUR : checksums differents'
