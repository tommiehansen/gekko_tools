#!/bin/bash
clear
echo "-------------------------------------------"
echo 'INSTALLING GEKKO + DEPENDECIES'
echo '-------------------------------------------'
echo 'This will take a while, go get some coffe'
sleep 3
sudo su
apt-get update -y && apt-upgrade -y && apt-get update -y
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
apt-get install nodejs -y
apt-get install build-essential -y
apt-get install git -y
cd /mnt/c/
mkdir www
cd www
git clone git://github.com/askmike/gekko.git
cd gekko
npm install --only=production
npm install tulind
apt-get install nano -y && apt-get install jed -y
apt-get autoremove -y
node gekko --ui