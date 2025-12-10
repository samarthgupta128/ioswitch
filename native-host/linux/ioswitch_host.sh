#!/bin/bash
# filepath: d:\projects\ioswitch\native-host\linux\ioswitch_host.sh
# IO Switch Native Messaging Host for Linux
# Opens URLs in a specific browser (not the default)

# Read message length (4 bytes, little-endian)
read_message() {
    # Read 4 bytes for length
    length_bytes=$(dd bs=1 count=4 2>/dev/null | od -An -td4 | tr -d ' ')
    
    if [ -z "$length_bytes" ] || [ "$length_bytes" -eq 0 ]; then
        exit 0
    fi
    
    # Read the message
    message=$(dd bs=1 count="$length_bytes" 2>/dev/null)
    echo "$message"
}

# Send response
send_response() {
    local response='{"success":true}'
    local length=${#response}
    
    # Write length as 4-byte little-endian
    printf "$(printf '\\x%02x\\x%02x\\x%02x\\x%02x' \
        $((length & 0xFF)) \
        $(((length >> 8) & 0xFF)) \
        $(((length >> 16) & 0xFF)) \
        $(((length >> 24) & 0xFF)))"
    
    # Write response
    printf '%s' "$response"
}

# Read the message
message=$(read_message)

# Extract URL from JSON
url=$(echo "$message" | grep -o '"url":"[^"]*"' | cut -d'"' -f4)

if [ -n "$url" ]; then
    # List of browsers to try (in order of preference)
    # Excludes Firefox since we're redirecting FROM Firefox
    browsers=(
        "google-chrome"
        "google-chrome-stable"
        "chromium"
        "chromium-browser"
        "microsoft-edge"
        "brave-browser"
        "vivaldi"
        "opera"
    )
    
    opened=false
    
    for browser in "${browsers[@]}"; do
        if command -v "$browser" &> /dev/null; then
            nohup "$browser" "$url" &>/dev/null &
            opened=true
            break
        fi
    done
    
    # Fallback: use xdg-open only if no specific browser found
    # (This might open Firefox again, but it's a last resort)
    if [ "$opened" = false ]; then
        nohup xdg-open "$url" &>/dev/null &
    fi
fi

# Send response
send_response