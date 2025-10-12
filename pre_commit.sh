#!/bin/bash

if [ -f "$1" ]; then
	set -a
    source "$1"
    set +a
fi

if [ -n "$ENCRYPT_KEY" ]; then
    cd "source_extra"
    echo "Compressing extra sources..."
    # Create a list of files to compress
    if [[ ! -f "list.txt" ]]; then
        echo "source_extra *.md *.html */" > "list.txt"
    fi
    # Update the archives
    while read -r archive_name file_paths; do
        echo "Updating $archive_name..."
        if [[ -z "$file_paths" ]]; then
            echo " -> Skipped"
            continue
        fi
        # Parse the file paths
        files_to_compress=""
        for file_path in $file_paths; do
            if [[ -e "$file_path" ]]; then
                files_to_compress="$files_to_compress $file_path"
            fi
        done
        if [[ -z "$files_to_compress" ]]; then
            echo " -> Skipped"
            continue
        fi
        # Compress the files
        tar -Jcvf "$archive_name.tar.xz" $files_to_compress
        if [[ $? != 0 ]]; then
            echo " -> Error"
            continue
        fi
        # Check & update the encrypted archive
        echo "Checking if update is needed..."
        sha256sum -c "$archive_name.tar.xz.sha256" 2> /dev/null
        if [[ $? != 0 ]]; then
            echo "Updating encrypted archive..."
            sha256sum "$archive_name.tar.xz" > "$archive_name.tar.xz.sha256"
            printf "$ENCRYPT_KEY" | tr -d '[\r\n]' | base64 -d | openssl enc \
                -aes-256-cbc -iter 256 -pbkdf2 \
                -in "$archive_name.tar.xz" -out "$archive_name.tar.xz.enc" \
                -pass stdin
        fi
    done < list.txt
    cd ".."
fi

echo "Done!"
