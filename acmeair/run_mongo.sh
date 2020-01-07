#Note: the machine where mongo is started must be specified in the mongo.properties file
# which is built into the liberty-acmeair container


docker run --rm --cpuset-cpus=16,17,48,49 --cpuset-mems=1 -d --net=host --name mongodb mongo-acmeair:latest --nojournal
sleep 2
docker exec mongodb mongorestore --drop /AcmeAirDBBackup 

#ssh mpirvu@192.168.1.7 "docker run --rm -d --net=host --name mongodb mongo-acmeair --nojournal"
#sleep 2
#ssh mpirvu@192.168.1.7 "docker exec mongodb mongorestore --drop /AcmeAirDBBackup"

