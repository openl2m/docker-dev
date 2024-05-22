#!/bin/bash

# We expect "/opt/openl2m" as the installation (git clone) directory for OpenL2M.
# if this is NOT the case, modify OPENL2M_DIR as needed!
# You will then also need to adjust the "docker-compose.yaml" and "Dockerfile" files...

OPENL2M_DIR=/opt/openl2m

echo "Starting OpenL2M Docker development preparation..."
echo

GIT=`which git`
if [ -z "${GIT}" ]; then
    echo "We cannot find 'git', please make sure it is installed!"
    exit 1
fi

# create compose override with base port mapping
if ! [ -f compose.override.yaml ]; then
    echo "Copying compose override file..."
    cp compose.override.example.yaml compose.override.yaml
fi

# check out OpenL2M sources, if needed:
if ! [ -d $OPENL2M_DIR ]; then
    while true; do
        read -p "OpenL2M install directory '$OPENL2M_DIR' not found, create it and download sources ? (y/n) " yn
        case $yn in
            [Yy] ) echo "Creating directory $OPENL2M_DIR ...";
                mkdir -p $OPENL2M_DIR
                if [ $? -ne 0 ]; then
                    echo "Error creating directory path!"
                    exit 1
                fi
                echo
                echo "Cloning sources ..."
                $GIT clone https://github.com/openl2m/openl2m.git $OPENL2M_DIR
                if [ $? -ne 0 ]; then
                    echo "Error downloading sources from git!"
                    exit 1
                fi
                break;;
            [Nn] ) echo Exiting...;
                exit;;
            * ) echo Invalid response;
                exit 1;;
        esac
    done
fi

# only copy new config first time:
BASEDIR=$OPENL2M_DIR/openl2m
if ! [ -f $BASEDIR/openl2m/configuration.py ]; then
    echo
    echo "Creating base configuration.py..."
    cp $BASEDIR/openl2m/configuration.example.py $BASEDIR/openl2m/configuration.py

    SECRET_KEY="${SECRET_KEY:-$($PYTHON3 $BASEDIR/generate_secret_key.py)}"
    echo "SECRET_KEY = '$SECRET_KEY'" >> $BASEDIR/openl2m/configuration.py

    cat <<EOF >> $BASEDIR/openl2m/configuration.py
DATABASE = {
    'NAME': 'openl2m',      # Database name
    'USER': 'openl2m',      # PostgreSQL username
    'PASSWORD': '${DB_PASS:-changeme}', # PostgreSQL password
    'HOST': 'postgres',                 # Database server
    'PORT': '${DB_PORT:-}',             # Database port (leave blank for default)
}
EOF

    echo ""
    echo "===> EDIT THIS FILE AS NEEDED: $BASEDIR/openl2m/configuration.py"
    echo ""
    echo "NOTE: if you change database credentials before you run the first time,"
    echo "      ALSO change them in docker-compose.yaml !!!!"
else
    echo
    echo "Configuration already exists! Please verify that database credentials are correct..."
    echo "(see $BASEDIR/openl2m/configuration.py)"
fi
