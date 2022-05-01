#!/bin/bash
_rootdir=$(dirname ${BASH_SOURCE})
_tempdir=$(mktemp -d /tmp/docker-$USER-XXXXXXXXXX)
_uid=$(id -u)
_gid=$(id -g)
_user=${USER}
_user_record=$(getent passwd $USER)
cat <<PASSWD >>${_tempdir}/passwd
sync:x:4:65534:sync:/bin:/bin/sync
games:x:5:60:games:/usr/games:/usr/sbin/nologin
man:x:6:12:man:/var/cache/man:/usr/sbin/nologin
lp:x:7:7:lp:/var/spool/lpd:/usr/sbin/nologin
mail:x:8:8:mail:/var/mail:/usr/sbin/nologin
news:x:9:9:news:/var/spool/news:/usr/sbin/nologin
uucp:x:10:10:uucp:/var/spool/uucp:/usr/sbin/nologin
proxy:x:13:13:proxy:/bin:/usr/sbin/nologin
www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
backup:x:34:34:backup:/var/backups:/usr/sbin/nologin
list:x:38:38:Mailing List Manager:/var/list:/usr/sbin/nologin
irc:x:39:39:ircd:/var/run/ircd:/usr/sbin/nologin
gnats:x:41:41:Gnats Bug-Reporting System (admin):/var/lib/gnats:/usr/sbin/nologin
nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin
_apt:x:100:65534::/nonexistent:/usr/sbin/nologin
systemd-timesync:x:101:101:systemd Time Synchronization,,,:/run/systemd:/usr/sbin/nologin
systemd-network:x:102:103:systemd Network Management,,,:/run/systemd:/usr/sbin/nologin
systemd-resolve:x:103:104:systemd Resolver,,,:/run/systemd:/usr/sbin/nologin
messagebus:x:104:105::/nonexistent:/usr/sbin/nologin
${_user_record}
PASSWD

cat <<SHADOW >>${_tempdir}/shadow
root:*:18906:0:99999:7:::
daemon:*:18906:0:99999:7:::
bin:*:18906:0:99999:7:::
sys:*:18906:0:99999:7:::
sync:*:18906:0:99999:7:::
games:*:18906:0:99999:7:::
man:*:18906:0:99999:7:::
lp:*:18906:0:99999:7:::
mail:*:18906:0:99999:7:::
news:*:18906:0:99999:7:::
uucp:*:18906:0:99999:7:::
proxy:*:18906:0:99999:7:::
www-data:*:18906:0:99999:7:::
backup:*:18906:0:99999:7:::
list:*:18906:0:99999:7:::
irc:*:18906:0:99999:7:::
gnats:*:18906:0:99999:7:::
nobody:*:18906:0:99999:7:::
_apt:*:18906:0:99999:7:::
systemd-timesync:*:18975:0:99999:7:::
systemd-network:*:18975:0:99999:7:::
systemd-resolve:*:18975:0:99999:7:::
messagebus:*:18975:0:99999:7:::
${_user}:!:18975:0:99999:7:::
SHADOW

cat <<GROUP >>${_tempdir}/group
root:x:0:
daemon:x:1:
bin:x:2:
sys:x:3:
adm:x:4:
tty:x:5:
disk:x:6:
lp:x:7:
mail:x:8:
news:x:9:
uucp:x:10:
man:x:12:
proxy:x:13:
kmem:x:15:
dialout:x:20:
fax:x:21:
voice:x:22:
cdrom:x:24:
floppy:x:25:
tape:x:26:
sudo:x:27:${_user}
audio:x:29:
dip:x:30:
www-data:x:33:
backup:x:34:
operator:x:37:
list:x:38:
irc:x:39:
src:x:40:
gnats:x:41:
shadow:x:42:
utmp:x:43:
video:x:44:
sasl:x:45:
plugdev:x:46:
staff:x:50:
games:x:60:
users:x:100:
nogroup:x:65534:
systemd-timesync:x:101:
systemd-journal:x:102:
systemd-network:x:103:
systemd-resolve:x:104:
messagebus:x:105:
ssh:x:106:
${_user}:x:${_gid}:${_user}
GROUP

docker run \
       -v ${_tempdir}/passwd:/etc/passwd:ro \
       -v ${_tempdir}/group:/etc/group:ro \
       -v ${_tempdir}/shadow:/etc/shadow:ro \
       -v ${HOME}:${HOME} \
       --privileged \
       -ti \
       -u $(id -u ${USER}):$(id -g ${USER}) rce/build_env:latest /bin/bash --login --norc --noprofile

rm -rf ${_tempdir}

