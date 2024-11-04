#!/bin/bash

git submodule update --init
if [ -z "$ASSETS_DIR" ]; then
    _submodule_status=($(git submodule status))
    ASSETS_DIR=${_submodule_status[1]}
fi
_path="$(pwd)"
cd "$ASSETS_DIR"
bash download_utils.sh
bash minify.sh image gallery
bash minify.sh html theme-material
cd "$_path"
cp -r "$ASSETS_DIR/public/"* public

echo "Done!"
