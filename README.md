

# destroy old cluster
fly volumes list | awk '/data/{print "fly volumes delete --yes "$1}' | sh
fly destroy yb --yes

# create 3 volumes in 3 regions
for reg in ord cdg ams ; do fly volumes create data --region $reg --size 10 ; done

# deploy to 3 VMs so that the yb-masters are crated
fly deploy
flyctl scale count 3
timeout 3 fly logs

# can scale more to create tservers - 6 in total
for reg in ord cdg ams ; do fly volumes create data --region $reg --size 10 ; done
flyctl scale count 6
timeout 90 fly logs

# check the servers are visible
fly ssh console
ysqlsh
select * from yb_servers();
# # Get the join IP
# sibling_ip=$(dig +short aaaa "${FLY_APP_NAME}.internal" @fdaa::3 | grep -Ev "$(hostname -i | awk '{print $1}')" | head -1)
# # Check if the join IP is equal to the current FLY_PRIVATE_IP
# if [[ $sibling_ip == "$FLY_PRIVATE_IP" ]]; then
#   join_ip=""
#   echo "The join IP is equal to the current FLY_PRIVATE_IP."
# else
#   join_ip="--join=[$sibling_ip]"
#   echo "The join IP is not equal to the current FLY_PRIVATE_IP."
# fi

# # Set the flags
# flags="placement_cloud=fly,placement_region=${FLY_REGION},placement_zone=zone,use_private_ip=cloud"

# # Set the file descriptor limit
# ulimit -n 1048576

# # Start YugabyteDB
# echo yugabyted start \
#   --advertise_address=[$FLY_PRIVATE_IP] \
#   --master_flags="$flags" \
#   --tserver_flags="ysql_enable_auth=true,$flags" $join_ip

# exec yugabyted start \
#   --advertise_address=[$FLY_PRIVATE_IP] \
#   --master_flags="$FLAGS" \
#   --tserver_flags="ysql_enable_auth=true,$FLAGS" $join_ip