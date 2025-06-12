#!/bin/sh

# install nginx with docker
install_gateway() {
    CONFIG_PATH=$(pwd)

    cat <<EOF >"$CONFIG_PATH/nginx.conf"
http {
    server {
        listen 80;

        location /rpc/ {
            proxy_pass http://host.docker.internal:8545/;
        }

        location / {
            proxy_pass http://host.docker.internal:8080/;
        }
    }
}
EOF

    docker run -d --name nginx-proxy \
        -v "$CONFIG_PATH/nginx.conf":/etc/nginx/nginx.conf:ro \
        -p 80:80 nginx
}
