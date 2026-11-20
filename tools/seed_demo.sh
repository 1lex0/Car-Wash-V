#!/usr/bin/env bash
set -euo pipefail
API=${1:-http://localhost:8080}
EMAIL=demo@2dwash.md
PASS=parola123
if [ -x /c/Windows/System32/curl.exe ]; then curl() { /c/Windows/System32/curl.exe "$@"; }; fi

TOKEN=$(curl -s -X POST "$API/auth/register" -H 'Content-Type: application/json' \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASS\",\"name\":\"Alex\"}" \
  | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')
if [ -z "$TOKEN" ]; then
  TOKEN=$(curl -s -X POST "$API/auth/login" -H 'Content-Type: application/json' \
    -d "{\"email\":\"$EMAIL\",\"password\":\"$PASS\"}" \
    | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')
fi

add() { # name area logo
  local logo=${3:+\"$3\"}
  curl -s -o /dev/null -w "%{http_code} $1\n" -X POST "$API/carwashes" \
    -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
    -d "{\"name\":\"$1\",\"area\":\"$2\",\"city\":\"Chișinău\",\"logoAsset\":${logo:-null}}"
}

add 'Lux Wash' 'Centru' 'assets/logos/Lux-wash.png'
add 'E-Wash' 'Rîșcani' 'assets/logos/E-wash.png'
add 'I-Wash' 'Botanica' 'assets/logos/I-wash.png'
for area in Centru Botanica Ciocana Buiucani Rîșcani Telecentru Sculeni; do
  add "Aqua $area" "$area"
  add "Clean Car $area" "$area"
  add "Мойка $area" "$area"
done

curl -s -o /dev/null -w "%{http_code} live I-Wash\n" -X PUT "$API/carwashes/3/live" \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d '{"waitingCarsCount":5,"bayCount":11,"occupiedBays":[3,6,10],"occupiedParkingSpots":[1,4,6]}'

echo "login в приложении: $EMAIL / $PASS"
