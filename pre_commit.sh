#!/bin/bash

if [ -f "$1" ]; then
	set -a
    source "$1"
    set +a
fi

if [ -z "$OUTPUT_PREFIX" ]; then
    OUTPUT_PREFIX=posts_ex
fi

if [ -n "$ENCRYPT_KEY" ]; then
    cd "source/_posts_enc"
    echo "Compressing special posts..."
    tar -Jcvf "$OUTPUT_PREFIX.tar.xz" *.md */
    echo "Checking if update is needed..."
    sha256sum -c "$OUTPUT_PREFIX.tar.xz.sha256" 2> /dev/null
    if [ $? != 0 ]; then
        echo "Updating encrypted archive..."
        sha256sum "$OUTPUT_PREFIX.tar.xz" > "$OUTPUT_PREFIX.tar.xz.sha256"
        printf "$ENCRYPT_KEY" | tr -d '[\r\n]' | base64 -d | openssl enc \
            -aes-256-cbc -iter 256 -pbkdf2 \
            -in "$OUTPUT_PREFIX.tar.xz" -out "$OUTPUT_PREFIX.tar.xz.enc" \
            -pass stdin
    fi
    cd "../.."
fi

echo "Done!"
