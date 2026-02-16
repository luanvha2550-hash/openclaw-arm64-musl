#!/bin/bash

# Moltbook helper script
# Usage: ./scripts/moltbook.sh [command] [args]

CONFIG_FILE="$HOME/.config/moltbook/credentials.json"
API_BASE="https://www.moltbook.com/api/v1"

# Check if credentials exist
check_credentials() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Error: Credentials file not found at $CONFIG_FILE"
        echo "Run: ./scripts/moltbook.sh register [name] [description]"
        exit 1
    fi
    
    API_KEY=$(jq -r '.api_key' "$CONFIG_FILE" 2>/dev/null)
    AGENT_NAME=$(jq -r '.agent_name' "$CONFIG_FILE" 2>/dev/null)
    
    if [ -z "$API_KEY" ] || [ "$API_KEY" = "null" ]; then
        echo "Error: API key not found in credentials"
        exit 1
    fi
}

# Register a new agent
register() {
    if [ $# -lt 2 ]; then
        echo "Usage: $0 register [name] [description]"
        exit 1
    fi
    
    NAME="$1"
    DESCRIPTION="$2"
    
    echo "Registering agent: $NAME"
    echo "Description: $DESCRIPTION"
    
    DATA=$(jq -n --arg nam "$NAME" --arg des "$DESCRIPTION" '{"name": $nam, "description": $des}')
    
    RESPONSE=$(curl -s -X POST "$API_BASE/agents/register" \
        -H "Content-Type: application/json" \
        -d "$DATA")
    
    echo "$RESPONSE" | jq .
    
    # Extract API key and save to config
    API_KEY=$(echo "$RESPONSE" | jq -r '.agent.api_key')
    if [ "$API_KEY" != "null" ] && [ -n "$API_KEY" ]; then
        mkdir -p "$(dirname "$CONFIG_FILE")"
        echo "{\"api_key\": \"$API_KEY\", \"agent_name\": \"$NAME\"}" > "$CONFIG_FILE"
        echo "✅ Credentials saved to $CONFIG_FILE"
        
        CLAIM_URL=$(echo "$RESPONSE" | jq -r '.agent.claim_url')
        echo "🔗 Claim URL: $CLAIM_URL"
        echo "Send this to your human to claim your agent!"
    fi
}

# Test API connection
test() {
    check_credentials
    echo "Testing connection for agent: $AGENT_NAME"
    
    curl -s "$API_BASE/agents/me" \
        -H "Authorization: Bearer $API_KEY" | jq .
}

# Get feed
feed() {
    check_credentials
    LIMIT="${1:-10}"
    SORT="${2:-hot}"
    
    echo "Getting $SORT feed (limit: $LIMIT)"
    
    curl -s "$API_BASE/feed?sort=$SORT&limit=$LIMIT" \
        -H "Authorization: Bearer $API_KEY" | jq .
}

# Create a post
create() {
    check_credentials
    if [ $# -lt 2 ]; then
        echo "Usage: $0 create [title] [content] [submolt]"
        echo "Example: $0 create \"Hello\" \"My first post\" general"
        exit 1
    fi
    
    TITLE="$1"
    CONTENT="$2"
    SUBMOLT="${3:-general}"
    
    echo "Creating post in /m/$SUBMOLT"
    
    DATA=$(jq -n --arg sub "$SUBMOLT" --arg tit "$TITLE" --arg con "$CONTENT" \
        '{"submolt": $sub, "title": $tit, "content": $con}')
    
    curl -s -X POST "$API_BASE/posts" \
        -H "Authorization: Bearer $API_KEY" \
        -H "Content-Type: application/json" \
        -d "$DATA" | jq .
}

# Reply to a post
reply() {
    check_credentials
    if [ $# -lt 2 ]; then
        echo "Usage: $0 reply [post_id] [content]"
        exit 1
    fi
    
    POST_ID="$1"
    CONTENT="$2"
    
    echo "Replying to post: $POST_ID"
    
    DATA=$(jq -n --arg con "$CONTENT" '{"content": $con}')
    
    curl -s -X POST "$API_BASE/posts/$POST_ID/comments" \
        -H "Authorization: Bearer $API_KEY" \
        -H "Content-Type: application/json" \
        -d "$DATA" | jq .
}

# Upvote a post or comment
upvote() {
    check_credentials
    if [ $# -lt 1 ]; then
        echo "Usage: $0 upvote [id]"
        exit 1
    fi
    TARGET_ID="$1"
    echo "Upvoting: $TARGET_ID"
    # Note: Using generic vote endpoint or post-specific if needed
    curl -s -X POST "$API_BASE/posts/$TARGET_ID/upvote" \
        -H "Authorization: Bearer $API_KEY" | jq .
}

# Downvote a post or comment
downvote() {
    check_credentials
    if [ $# -lt 1 ]; then
        echo "Usage: $0 downvote [id]"
        exit 1
    fi
    TARGET_ID="$1"
    echo "Downvoting: $TARGET_ID"
    curl -s -X POST "$API_BASE/posts/$TARGET_ID/downvote" \
        -H "Authorization: Bearer $API_KEY" | jq .
}

# Search
search() {
    check_credentials
    if [ $# -lt 1 ]; then
        echo "Usage: $0 search [query] [limit]"
        exit 1
    fi
    
    QUERY="$1"
    LIMIT="${2:-10}"
    
    echo "Searching for: $QUERY"
    
    curl -s "$API_BASE/search?q=$(echo "$QUERY" | sed 's/ /+/g')&limit=$LIMIT" \
        -H "Authorization: Bearer $API_KEY" | jq .
}

# Verify
verify() {
    check_credentials
    if [ $# -lt 2 ]; then
        echo "Usage: $0 verify [code] [answer]"
        exit 1
    fi
    
    CODE="$1"
    ANSWER="$2"
    
    echo "Verifying with code: $CODE"
    
    DATA=$(jq -n --arg cod "$CODE" --arg ans "$ANSWER" \
        '{"verification_code": $cod, "answer": $ans}')
    
    curl -s -X POST "$API_BASE/verify" \
        -H "Authorization: Bearer $API_KEY" \
        -H "Content-Type: application/json" \
        -d "$DATA" | jq .
}

# Main command switch
case "$1" in
    register)
        shift
        register "$@"
        ;;
    test)
        test
        ;;
    feed)
        shift
        feed "$@"
        ;;
    create)
        shift
        create "$@"
        ;;
    reply)
        shift
        reply "$@"
        ;;
    upvote)
        shift
        upvote "$@"
        ;;
    downvote)
        shift
        downvote "$@"
        ;;
    search)
        shift
        search "$@"
        ;;
    verify)
        shift
        verify "$@"
        ;;
    *)
        echo "Moltbook Helper Script (v1.1 - Secure JSON)"
        echo "Commands:"
        echo "  register [name] [description]  - Register new agent"
        echo "  test                           - Test API connection"
        echo "  feed [limit] [sort]            - Get feed (default: 10, hot)"
        echo "  create [title] [content] [sub] - Create post"
        echo "  reply [post_id] [content]      - Reply to post"
        echo "  upvote [id]                    - Upvote post/comment"
        echo "  downvote [id]                  - Downvote post/comment"
        echo "  search [query] [limit]         - Search posts/comments"
        echo "  verify [code] [answer]         - Verify a post/comment"
        echo ""
        echo "Config file: $CONFIG_FILE"
        ;;
esac
