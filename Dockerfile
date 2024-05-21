# # Use a Debian base image
# FROM debian:latest

# ENV YB_USER=yugabyte
# ENV YB_GROUP=yugabyte
# ENV YB_HOME=/home/yugabyte

# # Update package list and install required packages
# RUN apt-get update && apt-get install -y \
#     curl \
#     wget \
#     python-is-python3 python3-distutils \
#     procps \
#     iproute2 \
#     iputils-ping \
#     sudo \
#     && rm -rf /var/lib/apt/lists/*

# RUN groupadd -r $YB_GROUP && useradd -r -g $YB_GROUP -d $YB_HOME -s /bin/bash $YB_USER

# USER $YB_USER
# WORKDIR $YB_HOME

# RUN wget https://downloads.yugabyte.com/releases/2.21.0.1/yugabyte-2.21.0.1-b1-linux-x86_64.tar.gz
# RUN tar xvfz yugabyte-2.21.0.1-b1-linux-x86_64.tar.gz \
#   && cd yugabyte-2.21.0.1/ \
#   && ./bin/post_install.sh

# # Set entrypoint to start yugabyted
# # ENTRYPOINT ["/usr/local/bin/yugabyted"]
# ENTRYPOINT ["sleep", "infinity"]

FROM yugabytedb/yugabyte:latest
RUN yum update -y && yum install -y chrony

# Replace AF_INET with AF_INET6 in the ./bin/yugabyted file
RUN sed -i 's/\bAF_INET\b/AF_INET6/g' ./bin/yugabyted
ADD start .
RUN chmod a+x start
ENV RF=3

# Enable and start chrony
RUN systemctl enable chronyd

ENTRYPOINT ./start

