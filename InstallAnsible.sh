#A shell script to install Ansible on Red Hat Linux AMI
#takes 1 argument, which is the IPv4 address of the slave client to be added to the Ansible hosts file.
sudo yum update
sudo yum -y install python3
sudo alternatives --set python /usr/bin/python3
sudo yum -y install python3-pip
sudo pip3 install ansible --user
sudo mkdir -p /etc/ansible
echo $1 | sudo tee /etc/ansible/hosts
ssh-keygen -f .ssh/id_rsa -t rsa -N ''
echo 'Done'
