echo "*** start three shard servers, a config server and a mongos"

ps -A | grep mongo

echo "*** create directories"
mkdir data
mkdir data/shard0
mkdir data/shard1
mkdir data/shard2
mkdir data/cfg0
mkdir log

echo "*** start shard servers"
mongod --logpath ./log/r0.log --dbpath ./data/shard0 --port 37000 --fork --shardsvr --smallfiles --rest
mongod --logpath ./log/r1.log --dbpath ./data/shard1 --port 37001 --fork --shardsvr --smallfiles --rest
mongod --logpath ./log/r2.log --dbpath ./data/shard2 --port 37002 --fork --shardsvr --smallfiles --rest


echo "*** config servers - IN PROD THERE SHOULD BE THREE CONFIG SERVERS"
mongod --logpath log/cfg0.log --dbpath ./data/cfg0 --port 57000 --fork --configsvr --smallfiles --rest


echo "*** wait 10 seconds for servers to come up"                  
sleep 10
echo "*** now start the mongos on standard port 27017"
mongos --logpath log/mongos.log --logappend --upgrade --configdb localhost:57000 --fork 

echo "*** show mongo* processes"
ps -A | grep mongo

echo "*** show last line of log files"
tail -n 1 ./log/*.log

echo "*** connnecting to mongos and enable sharding"
mongo <<'EOF'
db.adminCommand( { addshard : "localhost:37000" } );
db.adminCommand( { addshard : "localhost:37001" } );
db.adminCommand( { addshard : "localhost:37002" } );
db.adminCommand({enableSharding: "music"})
db.adminCommand({shardCollection: "music.tracks", key: {"Artist":1}});
db.adminCommand({shardCollection: "music.foo", key: {random:1}});
sh.status()
EOF
#db.adminCommand({shardCollection: "music.tracks", key: {"Artist":1}});
#db.adminCommand({shardCollection: "music.foo", key: {random:1}});

echo "*** insert some test data"
mongoimport -d music -c tracks < /Users/astrid/mongodb/lehmanns/export_tracks.json 
mongoimport -d music -c albums < /Users/astrid/mongodb/lehmanns/export_albums.json 

