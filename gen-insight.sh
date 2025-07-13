# /usr/local/bin env

read -p "Enter article title: " title

Y="$(date +'%Y')"
FN="$(date +'%d-%m-%Y')"
TITLE="insights"

mkdir -p "$TITLE/$Y"

mkdir -p $TITLE/$Y/$FN
cat <<EOF > "$TITLE/$Y/$FN/$title.md"
---
tags:
  - 
---
EOF
