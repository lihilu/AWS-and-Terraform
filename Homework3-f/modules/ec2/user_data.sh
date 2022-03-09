#! /bin/bash
sudo apt update -y
sudo apt install nginx -y
echo "Grandpa's Whiskey at $HOSTNAME" | sudo tee /var/www/html/index.html
sudo systemctl restart nginx
sudo apt-get -y install awscli
sudo sh -c 'echo "#!/bin/bash \nsudo aws s3 cp /var/log/nginx/access.log  s3://s3bucketwiskey/logs" > /etc/cron.hourly/upload_to_s3.sh'
sudo chmod +x /etc/cron.hourly/upload_to_s3.sh
