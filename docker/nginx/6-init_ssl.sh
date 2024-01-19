#!/bin/sh

nginx_conf_dir="/etc/nginx/conf.d/"
certbot_live_dir="/etc/letsencrypt/live/"

for conf_file in "$nginx_conf_dir"*.conf; do
    if [ -f "$conf_file" ]; then
        # Extract domain name from the conf file
        domain_name=$(basename "$conf_file" .conf)

        # Check if the corresponding domain configuration exists in certbot's live directory
        certbot_domain_dir="$certbot_live_dir$domain_name"

        if [ -d "$certbot_domain_dir" ]; then
            echo "Domain configuration for $domain_name exists in certbot's live directory."
        else
            echo "Domain configuration for $domain_name does not exist in certbot's live directory. Acquiring SSL certificate..."

            # Run certbot to acquire the SSL certificate silently
            certbot --nginx -d $domain_name -m ADMIN_EMAIL --agree-tos --no-eff-email
            if [ $? -eq 0 ]; then
                echo "SSL certificate acquired successfully for $domain_name."
            else
                echo "Failed to acquire SSL certificate for $domain_name."
            fi
        fi
    fi
done