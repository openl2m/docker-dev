## OpenL2M Docker DEVELOPMENT Setup

IF YOU ARE LOOKING TO QUICKLY TEST OPENL2M:
see http://github.com/openl2m/docker-test

This directory contains the files to create a development instance of OpenL2M
in a docker container, using "docker compose". In doing so, you only have to
clone the sources, but do not have to install anything new in your environment!
(e.g. no postgresql, no python requirements, etc)

*Note: this is NOT meant to become a production setup!!!*

Requirements:

* a working knowledge of the Python 3 and the Django framework
* a working knowledge of various network management technologies (SNMP, vendor APIs, etc.)
* a working docker host.
* rights to create new containers.
* working knowledge of using docker with compose.

### How this works:

Following these steps you will clone the OpenL2M source files into the local (i.e. Docker host)
file system, at /opt/openl2m, where you can edit them with your favorite tools.

We then run a docker container setup with a PostgreSql database and Django test server for you,
so you don't have to install anything on the Docker host.

### IMPORTANT:

We expect "/opt/openl2m" as the installation (git clone) directory for OpenL2M.
If this is NOT the case, you need to modify the following files:
```
   - compose.yaml
   - dockerfile
   - prepare.sh, edit the BASEDIR variable.
```

### Installation

Below are steps that appear to work, with some additional testing hints...

1 - Go into the /opt directory
```
    cd /opt
```


2 - Clone the docker-dev repository, into /opt/openl2m-docker-dev
```
    git clone https://github.com/openl2m/docker-dev openl2m-docker-dev
```


3 - cd into the docker-dev directory
```
    cd openl2m-docker-dev
```

Note: the following steps assume source installation in the default directory, /opt/openl2m/.
If not, you will need to modify several of the docker files...


4 - prepare your source tree environment:

From the host OS shell, run

```
    ./prepare.sh
```

This will create the /opt/openl2m path, download sources, and create a basic configuration file.

Note: to do this manually, see prepare.sh for the various steps...


5 - Edit the default OpenL2M config as needed.
```
    nano /opt/openl2m/openl2m/configuration.py
```

Note: changes to DEBUG will need to be done by editing this file!


6 - edit the compose.override.yaml config as needed for your local needs.

E.g. by default port 8000 on the host is used to access the Django development web server.
You can map that wherever is needed for your setup.


7 - Start the containers:
```
    sudo docker compose up
```

The first time around, this will take a while, as various parts of the container environment are
being downloaded and built.

After a few minutes, if you get something like this, things are running:
    openl2m-1   |   Applying ...
    openl2m-1   | Updating Wireshark Ethernet database...
    openl2m-1   | Initialization done!

Test from a browser, to "http://<your-host-ip>:8000/". If you get the login screen, things are running!
Now hit Control-C, and run as a daemon:
```
    docker compose up -d
```


8 - Open a shell to the "openl2m" container, to create the superuser account:
```
    sudo docker exec -ti openl2m-development-openl2m-1 bash
```

In this new shell, run:
```
    cd /opt/openl2m
    source venv/bin/activate
    python3 manage.py createsuperuser
```

follow the prompts, and when done:
```
    exit
```

to get back to the host server shell environment.


9 - go back to the web site, login and develop/test as needed!


10 - stop when done. Run:
```
    docker compose down
```

Editing
-------

You can now edit the source files under /opt/openl2m. As the container is running the Django test web server,
any changes are immediately reloaded. Note that all templates are compiled each time, so those changes also
take into effect right away!

You can now test and commit changes locally, create pull requests at github.com, etc...
Note that Git branching is handled locally in the host source tree!

Any source file changes in the host /opt/openl2m tree will cause the Django test server to restart,
meaning you can immediately test on the web site.

Errors trigger a restart with a 10 second pause, allowing you to fix your code problems (see entrypoint.sh)

Updating documentation
----------------------

Documentation is only recompiled when the containers start. You can force a rebuild of the HTML files from inside the container:
```
     sudo docker exec -ti openl2m-development-openl2m-1 bash
```

Then run the following commands:
```
    cd /opt/openl2m/
    source venv/bin/activate
    cd docs
    make html
    exit
```

Other Things:
------------
* To clean up and rebuild the OpenL2M container to test new code (and leave the database intact):
```
    sudo docker compose build openl2m
```

Be patient, this copies files again, and reinstalls the python dependencies...
Next run this to restart the containers:
```
    sudo docker compose up -d
```
