set -e

dir="/home/vagrant/mediadrop"

echo "Updating package manager..."
sudo apt-get update

echo "Installing MySQL..."
echo "mysql-server mysql-server/root_password password secret" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password secret" | sudo debconf-set-selections

sudo apt-get install -f -y

sudo apt-get install -y \
     mysql-client \
     mysql-server

echo "Installing remaining dependencies..."
sudo apt-get install -y \
     git-core \
     libfreetype6-dev \
     libjpeg-dev \
     libmysqlclient-dev \
     python-dev \
     python-setuptools \
     python-virtualenv \
     zlib1g-dev

if [[ ! -d $dir ]]; then
    echo "Cloning MediaDrop into $dir..."
    git clone git://github.com/mediadrop/mediadrop.git $dir
fi

echo "Updating MediaDrop..."
cd $dir
git pull

if [[ ! -d "$dir/venv" ]]; then
    echo "Setting up virtualenv..."
    virtualenv --distribute --no-site-packages venv
fi

source venv/bin/activate

echo "Installing a recent version of distribute..."
easy_install -U distribute

echo "Running setup.py..."
python setup.py develop

if [[ ! -f "$dir/deployment.ini" ]]; then
    echo "Creating development config..."
    paster make-config MediaDrop deployment.ini
fi

echo "Updating SQLAlchemy URL..."
sed -i "s/mysql:\/\/username:pass@localhost\/dbname/mysql:\/\/root:secret@localhost\/mediadrop/g" deployment.ini


echo "Creating mediadrop database..."
mysql -u root --password=secret -e "create database if not exists mediadrop"

echo "Running setup-app..."
paster setup-app deployment.ini

echo "Setting up fulltext search..."
mysql -u root --password=secret mediadrop < setup_triggers.sql

# Start the app
# paster serve --reload deployment.ini
