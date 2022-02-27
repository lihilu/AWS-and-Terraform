locals {
  my-nginx-instance-userdata = <<USERDATA
#!/bin/bash
sudo apt update -y
sudo apt install nginx -y
sed -i "s/nginx/Grandpa's Whiskey at $HOSTNAME/g" /var/www/html/index.nginx-debian.html
sed -i '15,23d' /var/www/html/index.nginx-debian.html
service nginx restart
sudo sh -c 'echo -e "#!/bin/bash \nsudo aws s3 cp /var/log/nginx/access.log  s3://terraform-bucket-maya/logs" > /etc/cron.hourly/upload_to_s3.sh'
sudo chmod +x /etc/cron.hourly/upload_to_s3.sh
USERDATA
}