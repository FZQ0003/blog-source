#!/bin/bash

if [ -f "$1" ]; then
	set -a
    source "$1"
    set +a
fi

if [ -n "$ENCRYPT_TAGS_LIST" ]; then
    echo "Applying changes for config.encrypt.tags..."
	sed -i 's/#\s*\(\S*\)\s*\(secrets.ENCRYPT_TAGS_LIST\)/\1 '"$ENCRYPT_TAGS_LIST"'/g' _config.yml
fi

if [ -n "$ENCRYPT_KEY" ]; then
    cd "source_extra"
    find . -type f -name "*.tar.xz.enc" | while read -r archive; do
        prefix="${archive%%.tar.xz.enc}"
        echo "Decrypting $(basename $prefix)..."
        mv "$prefix.tar.xz" "$prefix.tar.xz.bak"
        printf "$ENCRYPT_KEY" | tr -d '[\r\n]' | base64 -d | openssl enc -d \
                -aes-256-cbc -iter 256 \
                -in "$prefix.tar.xz.enc" -out "$prefix.tar.xz" \
                -pass stdin
        echo "Checking..."
        sha256sum -c "$prefix.tar.xz.sha256" 2> /dev/null
        if [ $? != 0 ]; then
            echo "Warning: Check failed!"
            continue
        fi
        echo "Uncompressing special posts..."
        tar -Jxvf "$prefix.tar.xz" -C "../source"
    done
    cd ".."
fi

echo "Done!"
