SPARK_MASTER_IP="$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')"
echo "export SPARK_MASTER_IP=$SPARK_MASTER_IP" > ~/spark-1.5.0/conf/spark-env.sh
