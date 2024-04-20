#!/usr/bin/env bash

set -e

# deps: west, awk, sed

# make sure you have the following files from the https://github.com/zmkfirmware/zephyr/tree/v3.5.0%2Bzmk-fixes/ repo in the zephyr/ directory:
# zephyr/
# ├── submanifests
# │   └── optional.yaml
# └── west.yml

WEST_MANIFEST="$(west manifest --resolve)"
ALL_NAMES=()

while read -r url rev; do

    # filter slashes & .git at the end from url to create slug
    slug="$(echo $url | cut -d'/' -f 4- | sed 's./._.' | sed 's/.git//')"
    ALL_NAMES+=("\${$slug};")

    # https://github.com/<org|user>/<repo>/archive/<commit>.tar.gz
    tarball_url="$(echo $url | sed 's/\.git//')/archive/$rev.tar.gz"
    echo "$slug = builtins.fetchTarball { url = \"$tarball_url\"; sha256 = \"sha256:$(nix-prefetch-url --unpack $tarball_url --quiet)\"; };"
    #wget $tarball_url -O- --quiet | sha256sum | cut -d' ' -f1

done < <(awk '
 /name:/ { name=$2 }
 /url:/ { url=$2 }
 /revision:/ { revision=$2; print url, revision }
' <<EOF 
$WEST_MANIFEST
EOF
)

echo -e "\n\n\n${ALL_NAMES[@]}"
