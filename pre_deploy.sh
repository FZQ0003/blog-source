#!/bin/bash

if [ -f "$1" ]; then
	set -a
    source "$1"
    set +a
fi

if [ -z "$OUTPUT_PREFIX" ]; then
    OUTPUT_PREFIX=posts_ex
fi

if [ -n "$ENCRYPT_TAGS_LIST" ]; then
    echo "Applying changes for config.encrypt.tags..."
	sed -i 's/#\s*\(\S*\)\s*\(secrets.ENCRYPT_TAGS_LIST\)/\1 '"$ENCRYPT_TAGS_LIST"'/g' _config.yml
fi

if [ -n "$ENCRYPT_KEY" ]; then
    cd "source/_posts_enc"
    if [ -f "$OUTPUT_PREFIX.tar.xz.enc" ]; then
        echo "Decrypting archive..."
        printf "$ENCRYPT_KEY" | tr -d '[\r\n]' | base64 -d | openssl enc -d \
                -aes-256-cbc -iter 256 \
                -in "$OUTPUT_PREFIX.tar.xz.enc" -out "$OUTPUT_PREFIX.tar.xz" \
                -pass stdin
        echo "Checking..."
        sha256sum -c "$OUTPUT_PREFIX.tar.xz.sha256" 2> /dev/null
        if [ $? == 0 ]; then
            echo "Uncompressing special posts..."
            tar -Jxvf "$OUTPUT_PREFIX.tar.xz" -C ../_posts
        else
            echo "Warning: Check failed!"
        fi
    fi
    cd "../.."
fi

echo "Done!"
