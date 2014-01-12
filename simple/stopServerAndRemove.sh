killall mongo
killall mongod
ps -A | grep mongo
echo

echo delete files
rm -rf ./data
rm -rf ./log


