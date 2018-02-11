# Install Gekko in Windows bash

##### Prerequisites (required)

* Install Bash on Windows 10:
https://docs.microsoft.com/en-us/windows/wsl/install-win10
* C-drive in Windows (or change all references to c to any other drive you might have)

#### How-to
##### Simple way

1. Open bash
2. curl -sL https://raw.githubusercontent.com/tommiehansen/gekko_tools/master/wsl-install/gekko_install.sh | sudo bash -

##### Manual way

1. open bash (win-key + type 'bash' + ENTER)
2. sudo su
3. apt-get update -y && apt-upgrade -y && apt-get update -y
Above will take some time, expect it to take 10-20 minutes.
4. curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
5. apt-get install nodejs -y
6. apt-get install build-essential -y
7. apt-get install git -y
8. apt-get install jed && apt-get install nano
9. cd /mnt/c/
10. mkdir www
11. cd www
12. git clone git://github.com/askmike/gekko.git
13. cd gekko
14. npm install --only=production
15. npm install tulind
16. apt-get autoremove -y
17. node gekko --ui