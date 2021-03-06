#Makefile

clean:
	sudo rm -i -rf *~* && find . -name '*.pyc' -exec rm {} \;

install:
	sudo apt-get update
	sudo apt-get install -y libmysqlclient-dev
	sudo apt-get install -y python-dev
	sudo apt-get install -y libjpeg8-dev
	sudo apt-get install -y libtiff4-dev
	sudo apt-get install -y zlib1g-dev
	sudo apt-get install -y libfreetype6-dev
	sudo apt-get install -y liblcms1-dev
	sudo apt-get install -y libwebp-dev
	sudo apt-get install -y python-pip
	sudo pip install --upgrade pip
	sudo pip install -r requirements.txt

mysql:
	wget https://releases.hashicorp.com/vagrant/1.8.1/vagrant_1.8.1_x86_64.deb
	sudo dpkg -i vagrant_1.8.1_x86_64.deb
	rm vagrant_1.8.1_x86_64.deb
	vagrant plugin install vagrant-azure vagrant-env
	sudo apt-get install -y python-pip
	sudo pip install --upgrade pip
	sudo pip install paramiko PyYAML jinja2 httplib2 ansible
	sudo vagrant box add azure https://github.com/msopentech/vagrant-azure/raw/master/dummy.box --force
	./variables_entorno.sh
	cd despliegueMySQL && sudo vagrant up --provider=azure

test:
	export DJANGO_SETTINGS_MODULE=plucoapp.settings && nosetests

run:
	python manage.py runserver 0.0.0.0:8000

heroku:
	wget -O- https://toolbelt.heroku.com/install-ubuntu.sh | sh   # descargar herramienta heroku CLI
	heroku login
	heroku create
	git add .
	git commit -m "despliegue en heroku"
	git push heroku master
	heroku ps:scale web=1
	heroku open

docker_Local:
	sudo apt-get update
	sudo apt-get install -y docker.io
	sudo docker pull romilgildo/pluco
	sudo docker run -p 8000:8000 -t -i romilgildo/pluco /bin/bash

docker_Azure:
	sudo apt-get install -y fabric
	wget https://releases.hashicorp.com/vagrant/1.8.1/vagrant_1.8.1_x86_64.deb
	sudo dpkg -i vagrant_1.8.1_x86_64.deb
	rm vagrant_1.8.1_x86_64.deb
	vagrant plugin install vagrant-azure vagrant-env
	sudo vagrant box add azure https://github.com/msopentech/vagrant-azure/raw/master/dummy.box --force
	./variables_entorno.sh
	cd despliegueDocker && sudo vagrant up --provider=azure
	cd ..
	fab -H pluco@pruebas-pluco.cloudapp.net montar_docker

azure:
	sudo apt-get install -y fabric
	wget https://releases.hashicorp.com/vagrant/1.8.1/vagrant_1.8.1_x86_64.deb
	sudo dpkg -i vagrant_1.8.1_x86_64.deb
	rm vagrant_1.8.1_x86_64.deb
	vagrant plugin install vagrant-azure vagrant-env
	sudo apt-get install -y python-pip
	sudo pip install --upgrade pip
	sudo pip install paramiko PyYAML jinja2 httplib2 ansible
	sudo vagrant box add azure https://github.com/msopentech/vagrant-azure/raw/master/dummy.box --force
	./variables_entorno.sh
	cd despliegueAzure && sudo vagrant up --provider=azure

push:
	sudo git add -A .
	git status
	sudo despliegueAzure/escribirCommit.sh
	git push
	fab -H pluco@pluco-iv.cloudapp.net actualizar
	python manage.py syncdb
