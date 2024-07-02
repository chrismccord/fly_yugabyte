FROM yugabytedb/yugabyte:2.21.0.1-b1-x86_64
RUN yum update -y && yum install -y chrony cronie

# Replace AF_INET with AF_INET6 in the ./bin/yugabyted file until
# this PR is merged https://github.com/yugabyte/yugabyte-db/pull/22471
RUN sed -i 's/\bAF_INET\b/AF_INET6/g' ./bin/yugabyted

ADD start .
ADD fly_master_addrs .
ADD fly_replica_addrs .
ADD setup_read_replica_rf .
RUN chmod a+x start
RUN chmod a+x setup_read_replica_rf
RUN chmod a+x fly_master_addrs
RUN chmod a+x fly_replica_addrs

# Enable and start chrony
RUN systemctl enable chronyd

ENTRYPOINT ./start
