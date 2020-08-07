#A shell script to automate the initial Ansible install on Red Hat Linux AMI outputs the RSA key to import into the host instances.
sudo yum update
sudo yum -y install python3
sudo alternatives --set python /usr/bin/python3
sudo yum -y install python3-pip
sudo pip3 install ansible --user
sudo mkdir /etc/ansible
sudo mkdir ~/.ssh
sudo echo $1 >> /etc/ansible/hosts
ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''
cat id_rsa.pub
echo 'Done'
