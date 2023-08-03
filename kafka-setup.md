```
cd /opt/kafka/bin
./kafka-topics.sh --bootstrap-server 172.16.194.78:9092,172.16.194.79:9092,172.16.194.80:9092 --alter --topic healthchecks-topic --partitions 4
./kafka-topics.sh --bootstrap-server 172.16.194.78:9092,172.16.194.79:9092,172.16.194.80:9092 --alter --topic healthchecks-topic --partitions 4
./kafka-topics.sh --bootstrap-server 172.16.194.78:9092,172.16.194.79:9092,172.16.194.80:9092 --alter --topic Com.InitializationResource --partitions 5
./kafka-topics.sh --bootstrap-server 172.16.194.78:9092,172.16.194.79:9092,172.16.194.80:9092 --list
```
