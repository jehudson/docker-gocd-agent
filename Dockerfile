FROM gocd/gocd-agent-ubuntu-16.04:v18.12.0
MAINTAINER John Hudson <hudsonj@parliament.uk>

ENV AWS_DEFAULT_REGION='eu-west-1'
ENV EC2_INI_PATH=/etc/ansible/ec2.ini

USER root

# Install ansible requirements
RUN apt-get update && apt-get -y install --no-install-recommends \
    python git-core curl && \
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python get-pip.py

# Install ansible
ARG ANSIBLE_VERSION
RUN pip install pyyaml && \
#    pip install ansible==${ANSIBLE_VERSION}
     pip install ansible==2.7

# Copy config files

COPY files/ansible.cfg /etc/ansible/
COPY files/ec2.ini /etc/ansible/

ADD https://raw.github.com/ansible/ansible/devel/contrib/inventory/ec2.py /etc/ansible/inventory/hosts
RUN chmod 775 /etc/ansible/inventory/hosts

# Install packages
RUN apt-get install -y python-pip python-passlib python-setuptools python-dev build-essential default-jre apache2-utils software-properties-common 
RUN pip install bcrypt
RUN pip install credstash
RUN pip install awscli
RUN pip install docker-py
RUN pip install boto

# Get keys
RUN mkdir /home/go/.ssh
RUN credstash -r eu-west-1 get ssh/core-instances > /home/go/.ssh/core_instances.pem
RUN credstash -r eu-west-1 get ssh/core-bastion > /home/go/.ssh/core-bastion.pem
RUN credstash -r eu-west-1 get ssh/ecs-bastion > /home/go/.ssh/ecs-bastion.pem
RUN credstash -r eu-west-1 get ssh/ecs-instances > /home/go/.ssh/ecs-instances.pem
RUN credstash -r eu-west-1 get ssh/deployer_id_rsa > /home/go/.ssh/id_rsa
COPY files/ssh_config /home/go/.ssh/config
RUN chown -R go:go /home/go/.ssh/
RUN chmod -R 0600 /home/go/.ssh/
RUN chmod 0700 /home/go/.ssh
