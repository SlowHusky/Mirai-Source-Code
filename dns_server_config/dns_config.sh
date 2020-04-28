sudo apt install bind9 bind9utils bind9-doc
sudo cp ./bind9 /etc/default/bind9
sudo cp ./named.conf.options /etc/bind/named.conf.options
sudo cp ./named.conf.local /etc/bind/named.conf.local
sudo cp -r ./zones/ /etc/bind/
sudo  systemctl restart bind9
sudo ufw allow Bind9
