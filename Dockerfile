#
# Dockerfile to create a runtime container to develop and test OpenL2M.
# Note: this is NOT meant to become a production setup!!!
#
FROM ubuntu:24.04

# install required packages for python311 and a build environment
RUN apt-get update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y \
      python3 python3-pip python3-venv python3-dev build-essential software-properties-common \
      libxml2-dev libxslt1-dev libffi-dev libpq-dev libssl-dev zlib1g-dev \
      libldap2-dev libsasl2-dev libssl-dev snmpd snmp libsnmp-dev xmlsec1 \
      git curl wget vim nano

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# copy the startup script (a.k.a. entrypoint)
ADD entrypoint.sh /opt/
RUN chmod +x /opt/entrypoint.sh

WORKDIR /opt/openl2m

# and tell the container what to run at boot
ENTRYPOINT ["/opt/entrypoint.sh"]