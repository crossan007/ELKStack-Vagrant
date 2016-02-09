# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  
   config.vm.box = "ubuntu14_04"
   config.vm.network "forwarded_port", guest: 80, host: 8080
    config.vm.network "forwarded_port", guest: 5044, host: 5044
   config.vm.network "private_network", ip: "192.168.33.10"
   config.vm.synced_folder "logstash/", "/etc/logstash"
   config.vm.synced_folder "elastisearch/", "/etc/elastisearch"
   config.vm.synced_folder "certs/", "/etc/pki/tls/certs"

   config.vm.provider "virtualbox" do |vb|
		vb.gui = true
		vb.memory = "1024"
	end

  config.vm.provision "shell", inline: <<-SHELL 
	sudo apt-get update
	sudo apt-get -y install software-properties-common unzip
	sudo add-apt-repository -y ppa:webupd8team/java
	echo "deb http://packages.elastic.co/kibana/4.4/debian stable main" | sudo tee -a /etc/apt/sources.list
	wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
	echo "deb http://packages.elastic.co/elasticsearch/2.x/debian stable main" | sudo tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list
	echo 'deb http://packages.elasticsearch.org/logstash/2.2/debian stable main' | sudo tee /etc/apt/sources.list.d/logstash.list
	sudo apt-get update
	echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
	echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
	sudo apt-get -y install oracle-java8-installer
	sudo apt-get -y install elasticsearch
	sudo service elasticsearch restart
	sudo update-rc.d elasticsearch defaults 95 10
	sudo apt-get -y install kibana
	sudo update-rc.d kibana defaults 96 9
	sudo service kibana start
	sudo apt-get -y install nginx apache2-utils
	sudo htpasswd -c -b /etc/nginx/htpasswd.users vagrant vagrant
	sudo rm /etc/nginx/sites-available/default
	sudo cp /vagrant/nginx/default /etc/nginx/sites-available/default
	sudo service nginx restart
	sudo apt-get -y install logstash
	sudo mkdir -p /etc/pki/tls/certs
	sudo mkdir /etc/pki/tls/private
	cd /etc/pki/tls; sudo openssl req -subj '/CN=elk.local/' -x509 -days 3650 -batch -nodes -newkey rsa:2048 -keyout private/logstash-forwarder.key -out certs/logstash-forwarder.crt
	sudo service logstash restart
	sudo update-rc.d logstash defaults 96 9
	cd ~
	curl -L -O https://download.elastic.co/beats/dashboards/beats-dashboards-1.1.0.zip
	unzip beats-dashboards-*.zip
	cd beats-dashboards-*
	./load.sh
	cd ~
	curl -O https://raw.githubusercontent.com/elastic/filebeat/master/etc/filebeat.template.json
	curl -XPUT 'http://localhost:9200/_template/filebeat?pretty' -d@filebeat.template.json
	curl -XPUT 'http://localhost:9200/_template/filebeat?pretty' -d@filebeat.template.json

   SHELL
end
