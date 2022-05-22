## CRONTAB

* * * * * /usr/bin/flock /tmp/ssync.lock -c 'bash ~/ssync.sh'