#!/bin/bash -xe
apt update -y
apt install nodejs unzip wget npm mysql-server -y
#wget https://aws-tc-largeobjects.s3.us-west-2.amazonaws.com/CUR-TF-200-ACCAP1-1-DEV/code.zip -P /home/ubuntu
wget https://aws-tc-largeobjects.s3.us-west-2.amazonaws.com/CUR-TF-200-ACCAP1-1-91571/1-lab-capstone-project-1/code.zip -P /home/ubuntu
cd /home/ubuntu
unzip code.zip -x "resources/codebase_partner/node_modules/*"
cd resources/codebase_partner
npm install aws aws-sdk
mysql -u root -e "CREATE USER 'nodeapp' IDENTIFIED WITH mysql_native_password BY 'student12'";
mysql -u root -e "GRANT all privileges on *.* to 'nodeapp'@'%';"
mysql -u root -e "CREATE DATABASE STUDENTS;"
mysql -u root -e "USE STUDENTS; CREATE TABLE students(
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
APP_DB_USER=nodeapp
APP_DB_PASSWORD=student12
APP_DB_NAME=STUDENTS
APP_PORT=80
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