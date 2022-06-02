# SETUP

Configure example.conf file and renamed to ssync.conf

# CRONTAB

```
* * * * * /usr/bin/flock /tmp/ssync.lock -c 'bash ~/ssync.sh'
```