#!/bin/bash

#
# docker entrypoint file for developing and testing OpenL2M sources.
#
# Note: this is NOT meant to become a production setup!!!
#

echo "Starting OpenL2M initialization..."

# the directory where the Django projec starts:
BASEDIR=/opt/openl2m/openl2m
# Python version to install and use:
PYTHON3=python3.11
PIP3=pip3.11

echo "Working dir:"
pwd

#
# we assume the host has performed the following:
# - create a configuration.py, with proper database credentials
# - performed 'git checkout' to the desired branch
#

# install needed packages:
$PIP3 install -r requirements.txt

echo "Running OpenL2M Database updates..."
$PYTHON3 openl2m/manage.py migrate --no-input

# Recompile the documentation, these become Django static files!
echo "Updating HTML documentation..."
cd docs
make html
cd ..

echo "Collecting static files..."
$PYTHON3 openl2m/manage.py collectstatic --no-input

echo "Removing stale content types..."
$PYTHON3 openl2m/manage.py remove_stale_contenttypes --no-input

echo "Removing expired user sessions..."
$PYTHON3 openl2m/manage.py clearsessions

echo "Updating Wireshark Ethernet database..."
$PYTHON3 openl2m/lib/manuf/manuf/manuf.py --update

echo "Initialization done!"

echo "OpenL2M will now start FOR DEVELOPMENT PURPOSES ONLY!"
while true
do
    $PYTHON3 openl2m/manage.py runserver 0:8000 --insecure
    echo
    echo "Development server exited, likely due to a coding error!"
    echo "Restarting in 10 seconds, please fix your code..."
    sleep 10
    echo "Restarting Django development server..."
done
