#!/bin/bash
apt update
apt install -y python3 python3-pip nginx jq awscli

# Install Flask and psycopg2
pip3 install flask psycopg2-binary boto3

# Create app dir
mkdir -p /opt/app


# nginx config
echo 'server {
    listen 80;
    server_name _;
    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}' | sudo tee /etc/nginx/sites-available/flask_app
sudo ln -s /etc/nginx/sites-available/flask_app /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo systemctl reload nginx


# run app
nohup python3 app.py &
