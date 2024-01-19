#!/bin/sh

need_reload=false
for conf_file in /tmp/nginx/*.conf; do
    file_name=$(basename "$conf_file")
    dest_path="/etc/nginx/conf.d/$file_name"

    if [ ! -e "$dest_path" ]; then
        cp "$conf_file" "$dest_path"
        need_reload=true
    fi
done

if [ "$need_reload" = true ]; then
    nginx -s reload
fi