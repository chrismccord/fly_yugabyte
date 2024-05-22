FROM yugabytedb/yugabyte:2.21.0.1-b1-x86_64
RUN yum update -y && yum install -y chrony

# Replace AF_INET with AF_INET6 in the ./bin/yugabyted file until
# this PR is merged https://github.com/yugabyte/yugabyte-db/pull/22471
RUN sed -i 's/\bAF_INET\b/AF_INET6/g' ./bin/yugabyted

ADD start .
ADD init_cluster .
ADD join_new_master .
RUN chmod a+x start init_cluster join_new_master

# Enable and start chrony
RUN systemctl enable chronyd

ENTRYPOINT ./start
# ENTRYPOINT sleep infinity
