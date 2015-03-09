# https://gist.github.com/EHLOVader/9233230
#!/bin/bash

PID_FILE=/var/run/mailcatcher.pid
NAME=mailcatcher
PROG="/usr/bin/env mailcatcher"
USER=mailcatcher
GROUP=mailcatcher

start() {
	echo -n "Starting MailCatcher"
	if start-stop-daemon --stop --quiet --pidfile $PID_FILE --signal 0
	then
		echo " already running."
		exit
	fi
	start-stop-daemon \
		--start \
		--pidfile $PID_FILE \
		--make-pidfile \
		--background \
		--exec $PROG \
		--user $USER \
		--group $GROUP \
		--chuid $USER \
		-- \
		--foreground \
		--http-ip=0.0.0.0 \
		--http-port=1080 \
		--smtp-port=1025
	echo "."
	return $?
}

stop() {
	echo -n "Stopping MailCatcher"
	start-stop-daemon \
		--stop \
		--oknodo \
		--pidfile $PID_FILE
	echo "."
	return $?
}

restart() {
	stop
	start
}

case "$1" in
	start)
		start
		;;
	stop)
		stop
		;;
	restart)
		restart
		;;
	*)
		echo "Usage: $0 {start|stop|restart}"
		exit 1
		;;
esac
