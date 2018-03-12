#!/usr/bin/dumb-init /bin/sh

uid=${FLUENT_UID:-1000}

# check if a old fluent user exists and delete it
cat /etc/passwd | grep fluent
if [ $? -eq 0 ]; then
    deluser fluent
fi

# (re)add the fluent user with $FLUENT_UID
adduser -D -g '' -u ${uid} -h /home/fluent fluent

# chown home and data folder
chown -R fluent /home/fluent
chown -R fluent /fluentd

#change configuration，execute only on first start up
if [ $KAFKA_HOST ];then
	RUN sed -i "s|KAFKA_HOST|$KAFKA_HOST|" /fluentd/etc/fluent.conf
else  
    RUN sed -i "s|KAFKA_HOST|kafka|" /fluentd/etc/fluent.conf
fi
if [ $KAFKA_PORT ];then
	RUN sed -i "s|KAFKA_PORT|$KAFKA_PORT|" /fluentd/etc/fluent.conf
else  
    RUN sed -i "s|KAFKA_PORT|9092|" /fluentd/etc/fluent.conf
fi
if [ $KAFKA_TOPIC ];then
	RUN sed -i "s|KAFKA_TOPIC|$KAFKA_TOPIC|" /fluentd/etc/fluent.conf
else  
	RUN sed -i "s|KAFKA_TOPIC|migum_app_log|" /fluentd/etc/fluent.conf
fi

exec su-exec fluent "$@"
