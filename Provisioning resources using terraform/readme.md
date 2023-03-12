# Provisioning a Web-Server and Database-Server in AWS using Terraform

![image](https://user-images.githubusercontent.com/89118373/224540372-4c3c799e-4fd5-4a76-8587-2834c6afe91e.png)

## Steps

* Create VPC (Virtual Private Cloud).

* Create Two Subnets (Public & Private subnets)
* Create Security Group
* Internet Gateway (IGW)
* Route Table or Public subnet
* Route Table association
* Create Instance (web-server) and connection
* Create Elastic IP and associate the same with web-server
* Create Instance for DB Server 
* Create NAT gateway for the DB Server
* Create route table for NAT gateway and associate
