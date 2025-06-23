# /usr/local/bin env

Y="$(date +'%Y')"
FN="$(date +'%d-%m-%Y')"
TITLE="retrospectives"

mkdir -p "$TITLE/$Y"

cat <<EOF > "$TITLE/$Y/$FN.md"
---
tags:
  - 
---
EOF
