# Phase 2 – Creating a Basic Functional Web Application

## Objective

The objective of Phase 2 was to deploy a basic functional Student Records web application on a single Ubuntu EC2 instance inside a custom AWS virtual network.

This phase included:

- creating a custom VPC,
- configuring internet access,
- launching an EC2 instance,
- deploying the provided application,
- configuring MySQL,
- testing the application through the public IPv4 address.

--------------------------------------------------

## Created AWS Resources

| Resource Type | Name |
|---|---|
| VPC | phase2-vpc |
| Public Subnet | phase2-public-subnet-1 |
| Internet Gateway | phase2-igw |
| Route Table | phase2-public-route-table |
| Security Group | phase2-web-sg |
| EC2 Instance | phase2-web-server |
| Operating System | Ubuntu Server 24.04 LTS |

--------------------------------------------------

## Network Configuration

A custom VPC with CIDR block 10.0.0.0/16 was created manually.

Inside the VPC, one public subnet with CIDR block 10.0.1.0/24 was created and configured to automatically assign public IPv4 addresses.

An Internet Gateway was attached to the VPC, and a public route table was configured with the route:

0.0.0.0/0 → Internet Gateway

This allowed the EC2 instance to access the internet and be publicly accessible.

--------------------------------------------------

## Security Group Configuration

The security group allowed the following inbound traffic:

| Type | Port | Source |
|---|---|---|
| SSH | 22 | 0.0.0.0/0 |
| HTTP | 80 | 0.0.0.0/0 |
| Custom TCP | 3000 | 0.0.0.0/0 |

### SSH Note

Initially, SSH access was restricted to “My IP”, but EC2 Instance Connect failed to establish a connection in the AWS Academy lab environment.

To solve the issue and allow EC2 Instance Connect to work correctly, SSH access was temporarily allowed from:

0.0.0.0/0

In a production environment, SSH access should be restricted to trusted IP addresses or more secure access methods.

--------------------------------------------------

## EC2 Instance Setup

An Ubuntu Server 24.04 LTS EC2 instance was launched inside the custom VPC and public subnet.

The instance was configured with:

- public IPv4 access,
- the custom security group,
- EC2 Instance Connect access using the ubuntu user.

The following packages were installed:

- Node.js
- npm
- Git
- MySQL Server
- wget
- unzip

--------------------------------------------------

## Application Deployment

The provided AWS Academy Phase 2 user data script was used to:

- install required packages,
- download the application code,
- configure MySQL,
- create the STUDENTS database,
- create the students table,
- configure environment variables,
- start the Node.js application.

The script was executed using:

chmod +x userdata-phase2.sh
sudo ./userdata-phase2.sh

--------------------------------------------------

## Troubleshooting and Notes

After running the provided script, the application initially did not stay active on port 80.

Testing with:

curl http://localhost

showed that the application process was not running.

The Node.js process was checked using:

ps aux | grep node

The application was then manually started using the required environment variables:

cd /home/ubuntu/resources/codebase_partner

export APP_DB_HOST=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
export APP_DB_USER=nodeapp
export APP_DB_PASSWORD=student12
export APP_DB_NAME=STUDENTS
export APP_PORT=80

sudo -E npm start

After confirming that the application was running on port 80, it was later started in the background using:

nohup sudo -E npm start > /home/ubuntu/app.log 2>&1 &

This allowed the application to continue running after the terminal session was closed.

### Background Process Note

The provided script included a basic /etc/rc.local configuration, but during testing the application did not remain active after closing the terminal.

For this Phase 2 proof of concept, the application was started in the background using nohup.

In a production-ready deployment, this should be improved using:

- systemd
- PM2
- or a properly configured startup service

--------------------------------------------------

## Application Testing

The Student Records application was successfully accessed through the EC2 public IPv4 address:

http://98.94.77.121

The following operations were tested successfully:

- viewing student records,
- adding student records,
- editing student records,
- deleting student records.

--------------------------------------------------

## Screenshots

All screenshots related to Phase 2 are available inside:

docs/screenshots/

--------------------------------------------------

## Final Result

At the end of Phase 2, a fully functional Student Records web application was successfully deployed on a single Ubuntu EC2 instance inside a custom AWS VPC.

The application was accessible through the internet using the EC2 public IPv4 address, and all required CRUD operations worked correctly.

This phase represents the basic proof of concept before separating the database into Amazon RDS and implementing high availability and scalability in later phases.