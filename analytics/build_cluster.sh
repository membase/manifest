#!/bin/bash

if [ -z "$2" ]; then
  echo
  echo Usage: $0 \<manifest url\> \<branch\>
  echo e.g. $0 http://172.23.120.24/builds/latestbuilds/couchbase-server/spock/3519/couchbase-server-5.0.0-3519-manifest.xml
  exit 1
fi

(
  echo "<!-- #####"
  echo "     ##### GENERATED FILE, DO NOT MODIFY!"
  echo "     #####"
  echo "     ##### based on $1"
  echo "     ##### -->"
  curl $1 | awk -v regex="RELEASE.*spock" -v count="3" '$0 ~ regex { skip=count; next } --skip >= 0 { next } 1' \
      | awk -v regex="name=\"tlm\"" -v count="5" '$0 ~ regex { skip=count; next } --skip >= 0 { next } 1' \
      | awk -v regex="name=\"build\"" -v count="5" '$0 ~ regex { skip=count; next } --skip >= 0 { next } 1' \
      | sed -e '/name="voltron"/d' -e '/name="ns_server"/d' -e '/name="couchbase-cli"/d' -e '/name="query"/d' \
            -e '/name="testrunner"/d' -e '/"@.*@"/d' -e '$d'
  echo
  echo '  <!-- Analytics Additions -->'
  cat cluster_part_$2.xml | sed 1,2d

) | sed 's/[[:space:]]*$//' > cluster_$2.xml

git diff cluster_$2.xml
