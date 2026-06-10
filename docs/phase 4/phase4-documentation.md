# Phase 4 – Implementing High Availability and Scalability

## Introduction

The objective of Phase 4 was to improve the availability and scalability of the existing web application by implementing AWS load balancing and automatic scaling services. The architecture was enhanced using an Application Load Balancer (ALB) and Amazon EC2 Auto Scaling to ensure that the application remains available under increased load and can automatically recover from instance failures.

---

# Task 1 – Creating an Application Load Balancer

## Creating a Target Group

The first step was creating a Target Group that would contain the EC2 instances running the web application.

Configuration used:

* Target Type: Instance
* Protocol: HTTP
* Port: 3000
* Health Check Protocol: HTTP
* VPC: Default VPC

After creating the Target Group, the existing EC2 instance hosting the application was registered as a target.

### Health Check Verification

Initially, the target was reported as unhealthy because the Node.js application was not running automatically. After manually starting the application and verifying that port 3000 was listening, the target status changed to Healthy.

---

## Creating the Application Load Balancer

An Application Load Balancer was created to distribute incoming traffic across application instances.

Configuration:

* Load Balancer Type: Application Load Balancer
* Scheme: Internet-facing
* IP Address Type: IPv4
* Availability Zones:

  * us-east-1b
  * us-east-1d
* Listener:

  * HTTP (Port 80)

The load balancer was configured to forward traffic to the previously created Target Group.

### Verification

After the load balancer finished provisioning and the registered target became healthy, the application was successfully accessible through the ALB DNS endpoint.

---

# Task 2 – Implementing Amazon EC2 Auto Scaling

## Creating an Amazon Machine Image (AMI)

To allow Auto Scaling to launch identical application servers, an Amazon Machine Image (AMI) was created from the running EC2 instance.

The AMI contained:

* Operating System configuration
* Node.js installation
* Application source code
* Application dependencies
* Existing environment configuration

This ensured that newly launched instances would be identical to the original application server.

---

## Creating a Launch Template

A Launch Template was created using the newly generated AMI.

Configuration:

* AMI: Custom application AMI
* Instance Type: t3.micro
* Key Pair: Existing key pair
* Security Group: Existing application security group
* IAM Instance Profile: LabInstanceProfile

### User Data Configuration

A User Data script was added to automatically start the application whenever a new instance is launched.

```bash
#!/bin/bash
cd /home/ec2-user/resources/codebase_partner
nohup sudo npm start > app.log 2>&1 &
```

Without this script, newly created instances would boot successfully but the application would not start automatically.

---

## Creating the Auto Scaling Group

An Auto Scaling Group (ASG) was created using the Launch Template.

Configuration:

* Minimum Capacity: 1
* Desired Capacity: 1
* Maximum Capacity: 2
* Availability Zones:

  * us-east-1b
  * us-east-1d

The Auto Scaling Group was attached to the previously created Target Group so that all new instances would automatically be registered with the Application Load Balancer.

---

## Configuring Scaling Policies

A Target Tracking Scaling Policy was configured.

Settings:

* Policy Type: Target Tracking
* Metric: Average CPU Utilization
* Target Value: 50%

This policy allows AWS to automatically launch additional instances when CPU utilization increases and remove instances when demand decreases.

---

# Task 3 – Accessing the Application

After integrating the Application Load Balancer and Auto Scaling Group, the application was accessed using the ALB DNS endpoint.

The following operations were tested successfully:

* Viewing student records
* Adding student records
* Updating student records
* Deleting student records

The application remained fully functional while being served through the load balancer.

---

# Task 4 – Load Testing

## Preparing AWS Cloud9

AWS Cloud9 was used to generate application traffic and simulate multiple users accessing the system simultaneously.

The loadtest utility was installed and configured.

---

## Executing Load Testing

The following command was executed:

```bash
loadtest --rps 1000 -c 500 -k http://<ALB-DNS-NAME>
```

Parameters used:

* 1000 requests per second
* 500 concurrent connections
* Keep-alive enabled

---

## Load Test Results

Observed results:

* Completed Requests: 9,997
* Total Errors: 0
* Effective Requests Per Second: 1000
* Mean Latency: 2.1 ms

The application handled all requests successfully without failures.

---

## Auto Scaling Verification

During testing and manual capacity adjustments, Auto Scaling activity logs confirmed that:

* New EC2 instances were launched successfully.
* Unhealthy instances were automatically replaced.
* Instances were terminated when capacity was reduced.
* The Auto Scaling Group maintained the desired capacity at all times.

These events confirmed that both high availability and automatic recovery mechanisms were functioning correctly.

---

# Final Architecture

Internet Users

↓

Application Load Balancer (ALB)

↓

Target Group

↓

Auto Scaling Group (ASG)

↓

EC2 Application Instances

↓

Node.js Application

↓

MySQL Database

---

# Conclusion

Phase 4 successfully implemented a highly available and scalable AWS architecture. The Application Load Balancer provided traffic distribution across instances, while Amazon EC2 Auto Scaling enabled automatic instance creation, replacement, and capacity management. Load testing demonstrated that the application could sustain high traffic volumes while maintaining availability and performance.
