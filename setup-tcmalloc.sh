cp /etc/my.cnf /etc/my.cnf.bak
grep -qxF '[mysqld_safe]' /etc/my.cnf || echo '[mysqld_safe]' >> /etc/my.cnf
grep -qxF 'malloc-lib=/usr/lib64/libtcmalloc_minimal.so.4' /etc/my.cnf || echo 'malloc-lib=/usr/lib64/libtcmalloc_minimal.so.4' >> /etc/my.cnf

echo 'LD_PRELOAD=/usr/lib64/libtcmalloc_minimal.so.4' >> /etc/sysconfig/mysql

read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

yum install gperftools-libs -y
systemctl restart mysqld
sleep 15
systemctl status mysqld

read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

lsof -n |grep tcmalloc
systemctl start keepalived
