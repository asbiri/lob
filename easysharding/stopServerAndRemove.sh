echo "*** kill all mongo? processes and remove data and log directories"

killall mongo
killall mongod
killall mongos

rm -rf ./data
rm -rf ./log

echo "*** is there still any mongo process running?"
ps -A | grep mongo


