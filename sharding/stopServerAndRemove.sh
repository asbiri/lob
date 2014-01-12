# kill mongo? processes and remove data and log

killall mongo
killall mongod
killall mongos

ps -A | grep mongo
echo

echo delete files
rm -rf ./data
rm -rf ./log


