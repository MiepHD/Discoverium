#!/bin/bash

TMP_DIR='tmp'

mapfile -t apps < <(yq '.apps[]' apps.yml)

mkdir ${TMP_DIR}
cd ${TMP_DIR}

for app in "${apps[@]}"; do
  FILENAME=`echo ${app} | cut -f5 -d/`.yml
  wget -q ${app} -O ${FILENAME}
  RC=$?

  if [ ${RC} -ne 0 ]; then
    echo "Error: Downloading ${app}"
    exit 1
  fi
done

cat *.yml | grep -v '^app:$' | sed 's/^  name:/- name:/g' > ../repo/apps.yml

cd ..
rm -rf ${TMP_DIR}
