#!/bin/bash
# === Update system packages ===
yum update -y

# === Install Java (required for Jenkins) ===
sudo dnf update -y
sudo dnf install java-17-amazon-corretto -y


# === Add Jenkins repository and install Jenkins ===
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
yum install jenkins -y

# Enable and start Jenkins service
systemctl enable jenkins
systemctl start jenkins

# === Install Git ===
yum install git -y

# === Install Terraform ===
TERRAFORM_VERSION="1.9.8"
cd /usr/local/bin
curl -O https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# === Install kubectl ===
curl -o /usr/local/bin/kubectl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x /usr/local/bin/kubectl

# === Print versions to verify installation ===
echo "Jenkins version: $(jenkins --version 2>/dev/null)" >> /var/log/setup.log
echo "Git version: $(git --version)" >> /var/log/setup.log
echo "Terraform version: $(terraform version)" >> /var/log/setup.log
echo "kubectl version: $(kubectl version --client --short)" >> /var/log/setup.log
echo "Jenkins service status: $(systemctl is-active jenkins)" >> /var/log/setup.log

# === Open Jenkins port (8080) in firewall, if firewalld is present ===
if command -v firewall-cmd &> /dev/null
then
  firewall-cmd --permanent --add-port=8080/tcp
  firewall-cmd --reload
fi
