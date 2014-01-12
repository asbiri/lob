echo "any mongo? processes:"
ps -A | grep mongo
echo

echo make / reset dirs..
mkdir data
mkdir data/svr
mkdir log

echo
echo start mongod on default port..

mongod --fork --logpath ./log/svr.log --smallfiles --dbpath data/svr 

echo
echo wait 2 seconds for server to come up..
sleep 2

ps -A | grep mongo

tail -n 1 ./log/*.log

