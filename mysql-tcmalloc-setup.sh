# cmsang - 03/08/2023

# check xem có cái tcmalloc không?
# cài rồi thì out ra luôn
    lsof -n | grep tcmalloc && exit 1

# cấu hình mysql sử dụng tcmalloc
# nếu chưa có thì append cấu hình vào cuối file cấu hình

# đầu tiên cứ backup lại file cấu hình cũ cho nó lành
    cp /etc/my.cnf /etc/my.cnf.bak
    grep -qxF '[mysqld_safe]' /etc/my.cnf || echo '[mysqld_safe]' >> /etc/my.cnf
    grep -qxF 'malloc-lib=/usr/lib64/libtcmalloc_minimal.so.4' /etc/my.cnf || echo 'malloc-lib=/usr/lib64/libtcmalloc_minimal.so.4' >> /etc/my.cnf

    grep -qxF 'LD_PRELOAD=/usr/lib64/libtcmalloc_minimal.so.4' /etc/sysconfig/mysql || echo 'LD_PRELOAD=/usr/lib64/libtcmalloc_minimal.so.4' >> /etc/sysconfig/mysql
    cat /etc/sysconfig/mysql

# cài tcmalloc
    yum install gperftools-libs -y

# restart mysql
    systemctl restart mysqld
    sleep 15

# check xem mysql lên chưa
    systemctl status mysqld
    
# kiểm tra lại tcmalloc lên chưa
    lsof -n | grep tcmalloc

# start lại keepalived cho lành
    systemctl start keepalived
