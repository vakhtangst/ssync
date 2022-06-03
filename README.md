# SETUP

Configure example.conf file and renamed to ssync.conf

```
cd /tmp
git clone https://github.com/vakhtangst/ssync.git
mkdir -p ~/.ssync/
cp ssync/example.conf ~/.ssync/ssync.conf
mkdir -p ~/bin/
cp ssync/ssync.sh ~/bin/ssync.sh
rm -rf /tmp/ssync/
```
Configure ssync.conf

# CRONTAB

```
* * * * * /usr/bin/flock /tmp/ssync.lock -c 'bash ~/ssync.sh'
```