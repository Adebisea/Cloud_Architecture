# Flask Application Deployment on AWS

This project demonstrates a production-oriented deployment of a Flask web application on AWS, focusing on **security, automation, and real-world DevOps best practices**.

The solution uses **Terraform** for infrastructure provisioning, **Ansible (via AWS SSM)** for configuration management, and **GitHub Actions** for CI/CD.

---

## Project Goals

* Deploy a Flask application securely on AWS
* Automate infrastructure and application delivery
* Avoid SSH and static AWS credentials
* Follow least-privilege and production-style architecture
* Demonstrate real-world DevOps tooling and workflows

---

## High-Level Architecture

**Request Flow:**

User → Application Load Balancer → Nginx → Flask App → PostgreSQL (RDS)



---

## Technology Stack

* **Cloud Provider:** AWS
* **Infrastructure as Code:** Terraform
* **Configuration Management:** Ansible (SSM connection)
* **CI/CD:** GitHub Actions (OIDC-based authentication)
* **Web Server:** Nginx
* **Application:** Flask (Python)
* **Database:** PostgreSQL (RDS)
* **Secrets Management:** AWS SSM Parameter Store

---

## Infrastructure Design (Terraform)

Infrastructure is fully provisioned using Terraform and organized into reusable modules.

### VPC

* Custom VPC
* **4 subnets**:
  * 2 public subnets (ALB, NAT Gateway)
  * 2 private subnets (EC2, RDS)
* Subnets spread across **2 Availability Zones**
* Internet Gateway attached to the VPC
* NAT Gateway allows private subnets outbound internet access

---

### EC2 Instance
* Deployed in a **private subnet**
**Security Group Rules:**
  * Inbound: Port **80**, restricted to the VPC CIDR block
  * Outbound: Allowed
**IAM Permissions:**
  * Read access to **SSM Parameter Store** (database credentials)
  * AWS Systems Manager access (Session Manager)
  * S3 access for required object retrieval

> SSH access is completely disabled. All access is performed via AWS SSM.

---

### Database (RDS – PostgreSQL)
* PostgreSQL database deployed in private subnets
* Database username, password, and hostname stored in **SSM Parameter Store**
* Security Group:
  * Port **5432** open **only to the EC2 instance**

---

### Application Load Balancer (ALB)
* Internet-facing ALB deployed in public subnets
* Forwards HTTP traffic to the EC2 instance
* ALB access logs enabled
* Logs stored securely in an **S3 bucket**

---

### GitHub OIDC Authentication
* GitHub OIDC identity provider created using Terraform module
* Dedicated IAM role for GitHub Actions
* Role permissions:
  * EC2 read only access
  * S3 access
  * AWS SSM Session Manager

> This removes the need for AWS access keys in GitHub secrets.

---

## Configuration Management (Ansible)
Ansible is used for system configuration and application deployment, connecting to EC2 **via AWS SSM instead of SSH**.

### Key Features
* Dynamic inventory to automatically discover EC2 instance IDs
* Uses the Ansible SSM connection plugin
## Playbooks
1. **Dependencies Playbook**
   * Installs OS and Python dependencies
   * Creates and configures a Python virtual environment
2. **Application Deployment Playbook**
   * Deploys Flask application files
   * Configures Nginx as a reverse proxy
   * Runs the Flask app as a **systemd-managed service**

---

## CI/CD Pipeline (GitHub Actions)
### 1. Infrastructure Provisioning
* Triggers on changes to the `Infra/` directory
* Runs Terraform to create or update AWS resources
* Can also be triggered manually
### 2. Infrastructure Destruction
* Manual workflow
* Safely destroys all Terraform-managed resources
### 3. Application Deployment
* Runs Ansible playbooks using SSM
* Installs dependencies
* Deploys and starts the Flask application

---

## Setup & Deployment Guide
### Step 1: Configure GitHub Secrets
Add the following secrets to the GitHub repository:
* **REGION**
  * AWS region for deployment (e.g. `us-east-1`)

---
### Step 2: Provision Infrastructure
* Run the **Infrastructure Provisioning** workflow
* Either manually or by committing a change to the `infra/` directory
After completion:
* Retrieve the **GitHub OIDC IAM Role ARN** created by Terraform
* Add it as a GitHub secret:
```
EC2_GH_ROLE
```

---
### Step 3: Deploy the Application
* Trigger the **Application Deployment** workflow
* This installs dependencies and deploys the Flask app via Ansible
---

### Step 4: Access the Application
* Obtain the **ALB DNS name** from Terraform outputs or AWS Console
* Open it in a browser:

```
http://<alb-dns-name>
```
![Flask App UI](https://raw.githubusercontent.com/Adebisea/Cloud_Architecture/IAC/Images/flask_app_ui.jpeg)


---

## Design Decisions & Rationale

* **SSM instead of SSH:** Improves security and auditability
* **OIDC instead of IAM users:** Eliminates long-lived credentials
* **Private subnets for EC2 and RDS:** Reduces attack surface
* **Nginx + Flask:** Production-style reverse proxy setup
* **Terraform modules:** Improves maintainability and reuse

---

Built as a hands-on DevOps project to demonstrate cloud infrastructure design, automation, security best practices, and CI/CD workflows.

