#!/bin/bash
# Script para verificar serviços do Google (Gmail e Calendar)

set -e

TOKEN_FILE="/home/moltuser/.openclaw/workspace/config/google-tokens.json"
if [ ! -f "$TOKEN_FILE" ]; then
    echo "Token file not found: $TOKEN_FILE"
    exit 1
fi

ACCESS_TOKEN=$(jq -r '.access_token' "$TOKEN_FILE")
if [ -z "$ACCESS_TOKEN" ] || [ "$ACCESS_TOKEN" = "null" ]; then
    echo "No access token found in $TOKEN_FILE"
    exit 1
fi

echo "Checking Gmail labels..."
curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
    "https://gmail.googleapis.com/gmail/v1/users/me/labels" \
    | jq -r '.labels[].name' | head -5

echo ""
echo "Checking Calendar events for today..."
TODAY=$(date -u +"%Y-%m-%dT00:00:00Z")
TOMORROW=$(date -u -d "+1 day" +"%Y-%m-%dT00:00:00Z")

curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
    "https://www.googleapis.com/calendar/v3/calendars/primary/events?timeMin=${TODAY}&timeMax=${TOMORROW}&orderBy=startTime&singleEvents=true" \
    | jq -r '.items[] | "\(.start.dateTime // .start.date) - \(.summary // "No title")"' | head -5