#
# Dockerfile to create a runtime container to develop and test OpenL2M.
# Note: this is NOT meant to become a production setup!!!
#
FROM ubuntu:24.04

# install extra tools to run add-apt-repo, etc.
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get update && \
    apt-get install -y software-properties-common && \
    rm -rf /var/lib/apt/lists/*

# install Deadsnakes PPA to be able to load Python 3.11
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC add-apt-repository ppa:deadsnakes/ppa

# install required packages for python311 and a build environment
RUN apt-get update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y \
      python3.11 python3.11-distutils python3.11-venv python3.11-dev build-essential \
      libxml2-dev libxslt1-dev libffi-dev libpq-dev libssl-dev zlib1g-dev \
      libldap2-dev libsasl2-dev libssl-dev snmpd snmp libsnmp-dev git curl wget vim nano

# add PIP, not part of the distro:
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# pre-install the requirements. This saves time when images are stopped and rebuild/restarted.
RUN pip3.11 install -r https://raw.githubusercontent.com/openl2m/openl2m/bootstrap5/requirements.txt

# copy the startup script (a.k.a. entrypoint)
ADD entrypoint.sh /opt/
RUN chmod +x /opt/entrypoint.sh

WORKDIR /opt/openl2m

# and tell the container what to run at boot
ENTRYPOINT ["/opt/entrypoint.sh"]