#!/bin/bash
apt update
sudo apt install -y python3 
sudo apt install -y python3-pip
sudo apt install -y python3-venv
sudo apt install -y nginx jq

# Create venv
python3 -m venv venv
source venv/bin/activate

# Install Flask and psycopg2
pip install flask 
pip install psycopg2-binary 
pip install boto3
# Install ssm agent
sudo snap install amazon-ssm-agent --classic
sudo snap list amazon-ssm-agent
sudo snap start amazon-ssm-agent

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
cd ~
wget https://raw.githubusercontent.com/Adebisea/Cloud_Architecture/refs/heads/IAC/App/app.py
nohup python3 app.py &
