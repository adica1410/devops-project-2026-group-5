#!/bin/bash -xe
apt update -y
apt install nodejs unzip wget npm mysql-server -y
#wget https://aws-tc-largeobjects.s3.us-west-2.amazonaws.com/CUR-TF-200-ACCAP1-1-DEV/code.zip -P /home/ubuntu
wget https://aws-tc-largeobjects.s3.us-west-2.amazonaws.com/CUR-TF-200-ACCAP1-1-91571/1-lab-capstone-project-1/code.zip -P /home/ubuntu
cd /home/ubuntu
unzip code.zip -x "resources/codebase_partner/node_modules/*"
cd resources/codebase_partner
npm install aws aws-sdk

APP_DB_HOST=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
APP_DB_USER=your_db_user_here
APP_DB_PASSWORD=your_db_password_here
APP_DB_NAME=your_db_name_here
APP_PORT=your_app_port_here

mysql -u root -e "CREATE USER '${APP_DB_USER}' IDENTIFIED WITH mysql_native_password BY '${APP_DB_PASSWORD}';"
mysql -u root -e "GRANT all privileges on *.* to '${APP_DB_USER}'@'%';"
mysql -u root -e "CREATE DATABASE ${APP_DB_NAME};"
mysql -u root -e "USE ${APP_DB_NAME}; CREATE TABLE students(
            id INT NOT NULL AUTO_INCREMENT,
            name VARCHAR(255) NOT NULL,
            address VARCHAR(255) NOT NULL,
            city VARCHAR(255) NOT NULL,
            state VARCHAR(255) NOT NULL,
            email VARCHAR(255) NOT NULL,
            phone VARCHAR(100) NOT NULL,
            PRIMARY KEY ( id ));"
sed -i 's/.*bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl enable mysql
service mysql restart

cat > /home/ubuntu/resources/codebase_partner/.env <<EOF
APP_DB_HOST=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
APP_DB_USER=${APP_DB_USER}
APP_DB_PASSWORD=${APP_DB_PASSWORD}
APP_DB_NAME=${APP_DB_NAME}
APP_PORT=${APP_PORT}
EOF

chmod 600 /home/ubuntu/resources/codebase_partner/.env

set -a
source /home/ubuntu/resources/codebase_partner/.env
set +a

npm start &

echo '#!/bin/bash -xe
cd /home/ubuntu/resources/codebase_partner
set -a
source /home/ubuntu/resources/codebase_partner/.env
set +a
npm start' > /etc/rc.local
chmod +x /etc/rc.local