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
PYTHON3=python3
PIP3=pip3

echo "Working dir:"
pwd

./upgrade.sh

echo "Initialization done!"

echo "OpenL2M will now start FOR DEVELOPMENT PURPOSES ONLY!"

# Activate the virtual environment
source "venv/bin/activate"

while true
do
    $PYTHON3 openl2m/manage.py runserver 0:8000 --insecure
    echo
    echo "Development server exited, likely due to a coding error!"
    echo "Restarting in 10 seconds, please fix your code..."
    sleep 10
    echo "Restarting Django development server..."
done
