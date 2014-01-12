# start a replica set and tell it that it will be a shard0
mkdir data
mkdir data/shard0
mkdir data/shard0/r0
mkdir data/shard0/r1
mkdir data/shard0/r2
mkdir data/shard1
mkdir data/shard1/r3
mkdir data/shard1/r4
mkdir data/shard1/r5
mkdir log

mongod --replSet rs0 --logpath ./log/r0.log --dbpath ./data/shard0/r0 --port 37000 --fork --shardsvr --smallfiles
mongod --replSet rs0 --logpath ./log/r1.log --dbpath ./data/shard0/r1 --port 37001 --fork --shardsvr --smallfiles
mongod --replSet rs0 --logpath ./log/r2.log --dbpath ./data/shard0/r2 --port 37002 --fork --shardsvr --smallfiles

sleep 5
# connect to one server and initiate the set
mongo --port 37000 << 'EOF'
config = { _id: "rs0", members:[
          { _id : 0, host : "localhost:37000" },
          { _id : 1, host : "localhost:37001" },
          { _id : 2, host : "localhost:37002" }]};
rs.initiate(config)
EOF

echo shard 2
mongod --replSet rs1 --logpath ./log/r3.log --dbpath ./data/shard1/r3 --port 37003 --fork --shardsvr --smallfiles
mongod --replSet rs1 --logpath ./log/r4.log --dbpath ./data/shard1/r4 --port 37004 --fork --shardsvr --smallfiles
mongod --replSet rs1 --logpath ./log/r5.log --dbpath ./data/shard1/r5 --port 37005 --fork --shardsvr --smallfiles

sleep 5

mongo --port 37003 << 'EOF'
config = { _id: "rs1", members:[
          { _id : 0, host : "localhost:37003" },
          { _id : 1, host : "localhost:37004" },
          { _id : 2, host : "localhost:37005" }]};
rs.initiate(config)
EOF


echo
echo config servers

mkdir data/cfg0
mkdir data/cfg1
mkdir data/cfg2
mongod --logpath log/cfg0.log --dbpath ./data/cfg0 --port 57000 --fork --configsvr --smallfiles
mongod --logpath log/cfg1.log --dbpath ./data/cfg1 --port 57001 --fork --configsvr --smallfiles
mongod --logpath log/cfg2.log --dbpath ./data/cfg2 --port 57002 --fork --configsvr --smallfiles


# now start the mongos on a standard port
mongos --logpath log/mongos.log --logappend --upgrade --configdb localhost:57000,localhost:57001,localhost:57002 --fork
echo "Waiting 60 seconds for the replica sets to fully come online"
sleep 60
echo "Connnecting to mongos and enabling sharding"

# add shards and enable sharding on the test db
mongo <<'EOF'
db.adminCommand( { addshard : "rs0/"+"localhost:37000" } );
db.adminCommand( { addshard : "rs1/"+"localhost:37003" } );
db.adminCommand({enableSharding: "test"})
# db.adminCommand({shardCollection: "test.grades", key: {student_id:1}});
EOF

ps -A | grep mongo

tail -n 1 ./log/*.log
