#!/usr/bin/env bash
set -uo pipefail
API=localhost:8080
CURL=curl; [ -x /c/Windows/System32/curl.exe ] && CURL=/c/Windows/System32/curl.exe

run() {
  echo "\$ curl $*"
  "$CURL" -s -w '\n[HTTP %{http_code}]\n' "$@"
  echo
}
token_of() { sed -n 's/.*"token":"\([^"]*\)".*/\1/p'; }

case "${1:-notes}" in
notes)
  run -i "$API/notes" | grep -E '^\$|^HTTP/|^\{|^\[HTTP'
  EMAIL=${EMAIL:-ana@test.md}
  BODY="{\"email\":\"$EMAIL\",\"password\":\"parola123\",\"name\":\"Ana\"}"
  run -X POST "$API/auth/register" -H 'Content-Type: application/json' -d "$BODY"
  run -X POST "$API/auth/register" -H 'Content-Type: application/json' -d "$BODY" # 409
  T=$("$CURL" -s -X POST "$API/auth/login" -H 'Content-Type: application/json' \
      -d "{\"email\":\"$EMAIL\",\"password\":\"parola123\"}" | token_of)
  echo "\$ curl $API/notes -H 'Authorization: Bearer \$TOKEN'"
  "$CURL" -s -w '\n[HTTP %{http_code}]\n\n' "$API/notes" -H "Authorization: Bearer $T"
  echo "\$ curl -X POST $API/notes -H 'Authorization: Bearer \$TOKEN' -H 'Content-Type: application/json' -d '{\"title\":\"Покупки\",\"content\":\"молоко, хлеб\"}'"
  "$CURL" -s -w '\n[HTTP %{http_code}]\n\n' -X POST "$API/notes" -H "Authorization: Bearer $T" \
    -H 'Content-Type: application/json' -d '{"title":"Покупки","content":"молоко, хлеб"}'
  echo "\$ curl -G $API/notes --data-urlencode 'search=Покуп' -H 'Authorization: Bearer \$TOKEN'"
  "$CURL" -s -w '\n[HTTP %{http_code}]\n' -G "$API/notes" --data-urlencode 'search=Покуп' \
    -H "Authorization: Bearer $T"
  ;;
theme)
  EMAIL=${EMAIL:-ion@test.md}
  BODY="{\"email\":\"$EMAIL\",\"password\":\"parola123\",\"name\":\"Ion\"}"
  echo "\$ curl -X POST $API/auth/register -H 'Content-Type: application/json' -d '$BODY'"
  R=$("$CURL" -s -w '\n[HTTP %{http_code}]' -X POST "$API/auth/register" \
      -H 'Content-Type: application/json' -d "$BODY")
  echo "$R"; echo
  T=$(echo "$R" | token_of)
  echo "\$ curl -i $API/carwashes            # без token-а"
  "$CURL" -s -i "$API/carwashes" | grep -E '^HTTP/|^\{'; echo
  for body in '{"name":"Aqua Ботаника","area":"Botanica","city":"Chișinău"}' \
              '{"name":"Lux Centru","area":"Centru","city":"Chișinău"}'; do
    echo "\$ curl -X POST $API/carwashes -H 'Authorization: Bearer \$TOKEN' -H 'Content-Type: application/json' -d '$body'"
    "$CURL" -s -w '\n[HTTP %{http_code}]\n\n' -X POST "$API/carwashes" \
      -H "Authorization: Bearer $T" -H 'Content-Type: application/json' -d "$body"
  done
  echo "\$ curl -X POST $API/carwashes -H 'Authorization: Bearer \$TOKEN' -H 'Content-Type: application/json' -d '{\"name\":\"\",\"area\":\"Centru\",\"city\":\"Chișinău\"}'"
  "$CURL" -s -w '\n[HTTP %{http_code}]\n\n' -X POST "$API/carwashes" -H "Authorization: Bearer $T" \
    -H 'Content-Type: application/json' -d '{"name":"","area":"Centru","city":"Chișinău"}'
  echo "\$ curl -G $API/carwashes --data-urlencode 'search=Ботан' -H 'Authorization: Bearer \$TOKEN'"
  "$CURL" -s -w '\n[HTTP %{http_code}]\n\n' -G "$API/carwashes" --data-urlencode 'search=Ботан' \
    -H "Authorization: Bearer $T"
  echo "\$ curl $API/carwashes/1 -H 'Authorization: Bearer \$TOKEN'   # мойка demo-пользователя"
  "$CURL" -s -w '\n[HTTP %{http_code}]\n' "$API/carwashes/1" -H "Authorization: Bearer $T"
  ;;
esac
