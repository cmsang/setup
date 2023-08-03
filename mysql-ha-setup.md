https://baotri.misa.vn/browse/TSDR-154702

# ################################################# #

1. replace ip
10.64.192.83
10.64.192.84
10.64.192.85

2. replace pass pass replica
12345678@Abc44

3.  replace pass keepalived
44444444

4. replace router_id keepalived
router_id mysql-441
router_id mysql-442

5. replace virtual_router_id nhu trong tsdr
virtual_router_id 122

6. replace conf
server-id=44
max_connections = 3000
innodb_buffer_pool_size = 12G

# ################################################# #
``` Replace xong thi trien thoi

1. Open Firewall 
Check rule truoc: Print the rules in a chain or all chains
--> iptables -S
chua co thi them rule:
    iptables -I  INPUT -p tcp -m tcp --dport 3306 -j ACCEPT
    service iptables save
    service iptables reload

Sửa cấu hình:
my.conf


skip-grant-tables
bind-address=0.0.0.0
server-id=44
log_bin=mysql-bin

open_files_limit=65535
innodb_flush_method=O_DIRECT
log_bin_trust_function_creators=1
performance_schema_digests_size=30000
performance_schema_max_digest_sample_age=0



systemctl restart mysqld & sleep 6
systemctl status mysqld


2. Config 
voi 2 node lam theo cac buoc sau
Nhớ thay IP tương ứng

 - Open and edit /etc/my.cnf or /etc/mysql/my.cnf, depending on your distribution.
 - Add skip-grant-tables under [mysqld]
 - Restart MySQL
 - You should be able to log in to MySQL now using the below command mysql -u root
 - Run mysql> flush privileges;

2.1 Tạo user replica
--> nên tách user khỏi user của app

FLUSH PRIVILEGES;

CREATE USER if not exists 'replica'@'%' IDENTIFIED BY '12345678@Abc44';
ALTER USER 'replica'@'%' IDENTIFIED WITH mysql_native_password BY '12345678@Abc44';
GRANT REPLICATION SLAVE ON *.* TO 'replica'@'%';
FLUSH PRIVILEGES;


CREATE USER if not exists 'mimosaonline'@'%' IDENTIFIED BY '12345678@Abc';
ALTER USER 'mimosaonline'@'%' IDENTIFIED WITH mysql_native_password BY '12345678@Abc';
GRANT ALL PRIVILEGES ON *.* TO 'mimosaonline'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

CREATE USER if not exists'exporter'@'%' IDENTIFIED WITH mysql_native_password BY '12345678@Abc' WITH MAX_USER_CONNECTIONS 20;
ALTER USER 'exporter'@'%' WITH MAX_USER_CONNECTIONS 20;
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'%';
GRANT DROP ON performance_schema.events_statements_summary_by_digest TO 'exporter'@'%';
GRANT DROP ON performance_schema.events_statements_history_long TO 'exporter'@'%';
FLUSH PRIVILEGES;

-- ----------------

systemctl restart mysqld & sleep 8
systemctl status mysqld

2.2 Lấy thông tin log_file và log_pos (2 tham số để 2 server replication vs nhau)
--> log_file và log_pos của node này sẽ dc truyền làm tham số cấu hình của node còn lại

2.3 Cấu hình slave thôi:
--> Chú ý IP của master nhé!

-- 10.64.192.83

SHOW MASTER STATUS;
STOP SLAVE;
CHANGE  MASTER TO MASTER_HOST='10.64.192.84', MASTER_USER='replica', MASTER_PASSWORD='12345678@Abc44', MASTER_LOG_FILE='mysql-bin.000002', MASTER_LOG_POS=157;

START SLAVE;
SHOW SLAVE STATUS;


-- 10.64.192.84
SHOW MASTER STATUS;
STOP SLAVE;
CHANGE  MASTER TO MASTER_HOST='10.64.192.83', MASTER_USER='replica', MASTER_PASSWORD='12345678@Abc44', MASTER_LOG_FILE='mysql-bin.000002', MASTER_LOG_POS=157;

START SLAVE;
SHOW SLAVE STATUS;

3. Install keepalived và config VIP
3.1 bật cấu hình cho phép cài VIP lên card mạng
    cat /etc/sysctl.conf
    echo net.ipv4.ip_nonlocal_bind=1 >> /etc/sysctl.conf
    sysctl -p


3.2 Cài keepalived
check keepalived đã đc cài chưa --> keepalived --version


    
    hostname | grep a && sudo cp /root/cmsang-keepalived/config-ha/mysql/keepalived.master.conf /root/cmsang-keepalived/keepalived-2.2.7/keepalived/etc/keepalived/keepalived.conf
    hostname | grep b && sudo cp /root/cmsang-keepalived/config-ha/mysql/keepalived.backup.conf /root/cmsang-keepalived/keepalived-2.2.7/keepalived/etc/keepalived/keepalived.conf

    cd /root/cmsang-keepalived/
    unzip node_exporter_v1.0.1.zip
    sudo bash node_exporter/install_nodeexporter.sh

    cd /root/cmsang-keepalived/keepalived-2.2.7
    chmod +x ./configure
    ./configure
    make && make install 

    sudo  mv /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.bak

    sudo cp ./keepalived/keepalived /usr/sbin/
    sudo cp ./keepalived/etc/init.d/keepalived /etc/init.d/
    mkdir /etc/keepalived
    sudo cp ./keepalived/etc/sysconfig/keepalived /etc/sysconfig/keepalived
    sudo cp ./keepalived/etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf
    mkdir /etc/keepalived/bin
    sudo cp ./keepalived/etc/keepalived/bin/mysql.sh /etc/keepalived/bin/mysql.sh
    sudo cp ./keepalived/etc/keepalived/bin/start_keepalived_if_inactive.sh /etc/keepalived/bin/start_keepalived_if_inactive.sh
    chmod +x /etc/keepalived/bin/mysql.sh
    chmod +x /etc/keepalived/bin/start_keepalived_if_inactive.sh

    systemctl enable keepalived 
    systemctl restart keepalived
    systemctl status keepalived
    systemctl restart ntpd
    systemctl enable ntpd

    lsof -n | grep tcmalloc && exit 1

    cp /etc/my.cnf /etc/my.cnf.bak
    grep -qxF '[mysqld_safe]' /etc/my.cnf || echo '[mysqld_safe]' >> /etc/my.cnf
    grep -qxF 'malloc-lib=/usr/lib64/libtcmalloc_minimal.so.4' /etc/my.cnf || echo 'malloc-lib=/usr/lib64/libtcmalloc_minimal.so.4' >> /etc/my.cnf

    grep -qxF 'LD_PRELOAD=/usr/lib64/libtcmalloc_minimal.so.4' /etc/sysconfig/mysql || echo 'LD_PRELOAD=/usr/lib64/libtcmalloc_minimal.so.4' >> /etc/sysconfig/mysql
    cat /etc/sysconfig/mysql

    yum install gperftools-libs -y
    systemctl restart mysqld
    sleep 15
    systemctl status mysqld

    lsof -n | grep tcmalloc
    systemctl start keepalived

    lsof -n | grep tcmalloc

    # lsof -n | grep tcmalloc && exit 1

    # yum install keepalived -y
    
3.3 Cấu hình cho phép VIP trafic qua iptables
Check lại rule có chưa cho chắc --> iptables -S
    iptables -I INPUT -p vrrp -j ACCEPT
    service iptables save
    service iptables reload



4. Làm cái cronjob start keepalived if dead cho nó nhàn
4.1
    #!/bin/bash

    SERVICENAME="keepalived"

    systemctl is-active --quiet $SERVICENAME
    STATUS=$? # return value is 0 if running

    if [[ "$STATUS" -ne "0" ]]; then
        systemctl start $SERVICENAME
    fi

4.3
crontab -e

# min   hour    day month   dow cmd

*/10 *   *   *   *   /etc/keepalived/bin/start_keepalived_if_inactive.sh



5. Check kết quả
ip addr show ens192
 
-- ---------------------------------------


open_files_limit=65535
innodb_flush_method=O_DIRECT
log_bin_trust_function_creators=1
performance_schema_digests_size=30000
performance_schema_max_digest_sample_age=0

-- ---------------------------------------
6. cài tcmalloc


systemctl restart mysqld
sleep 15
systemctl status mysqld

systemctl start keepalived

lsof -n | grep tcmalloc && exit 1

cp /etc/my.cnf /etc/my.cnf.bak
grep -qxF '[mysqld_safe]' /etc/my.cnf || echo '[mysqld_safe]' >> /etc/my.cnf
grep -qxF 'malloc-lib=/usr/lib64/libtcmalloc_minimal.so.4' /etc/my.cnf || echo 'malloc-lib=/usr/lib64/libtcmalloc_minimal.so.4' >> /etc/my.cnf

grep -qxF 'LD_PRELOAD=/usr/lib64/libtcmalloc_minimal.so.4' /etc/sysconfig/mysql || echo 'LD_PRELOAD=/usr/lib64/libtcmalloc_minimal.so.4' >> /etc/sysconfig/mysql
cat /etc/sysconfig/mysql

yum install gperftools-libs -y
systemctl restart mysqld
sleep 15
systemctl status mysqld

lsof -n | grep tcmalloc
systemctl start keepalived

lsof -n | grep tcmalloc && exit 1





=========================================

slave_skip_errors=1032,1049,1062,1304,1060,1146,1008

error_code  error_message
1049    Worker 1 failed executing transaction 'ANONYMOUS' at master log mysql-bin.000050, end_log_pos 520636331; Error executing row event: 'Unknown database 'g1_2a46afa64d9f4f97be0cb3252816a4f3_0001''
1032    Worker 1 failed executing transaction 'ANONYMOUS' at master log mysql-bin.000124, end_log_pos 566658254; Could not execute Update_rows event on table g1_fb47f24a974546deb0001ecb185ae59d_0001.search_voucher; Can't find record in 'search_voucher', Error_code: 1032; handler error HA_ERR_KEY_NOT_FOUND; the event's master log FIRST, end_log_pos 566658254
1062	Worker 1 failed executing transaction 'ANONYMOUS' at master log mysql-bin.000124, end_log_pos 566663150; Could not execute Write_rows event on table g1_fb47f24a974546deb0001ecb185ae59d_0001.msc_auditting_log; Duplicate entry '53' for key 'msc_auditting_log.PRIMARY', Error_code: 1062; handler error HA_ERR_FOUND_DUPP_KEY; the event's master log mysql-bin.000124, end_log_pos 566663150
1304	Worker 1 failed executing transaction 'ANONYMOUS' at master log mysql-bin.000127, end_log_pos 377152765; Error 'PROCEDURE proc_far_decrease_fixed_asset already exists' on query. Default database: 'g1_6056e8cbfe3049e983e363a3edfa5ab1_0001'. Query: 'CREATE DEFINER=`mimosaonline`@`%` PROCEDURE `proc_far_decrease_fixed_asset`(IN fromDate datetime,
IN toDate datetime,
IN departmentId varchar(255),
IN fixedAssetIdList longtext,
IN fixedAssetCategoryId char(36))
    COMMENT 'Sổ ghi giảm tài sản cố định'
BEGIN
  -- =============================================
  -- Author: TPNAM
  -- Create date: 16/01/2023
  -- Description: hàm lấy dữ liệu sổ ghi giảm tài sản cố định
  -- call [proc_far_decrease_fixed_asset]('2023-01-01','2023-12-31','1D496496-AEB2-4EA9-8F1A-5859227AC7E6','','068643bc-85c6-11ed-be2c-005056b30259')
  -- ============================================= 
  DECLARE $fixAssetDecrementReftype int;
  DECLARE $faDepartmentTransfer int;
  DECLARE $faAdjustment int;
  DECLARE $str

1060  Error 'Duplicate column name 'account_category'' on query. Default database: 'g1_5dddcd37c81e4bc29d95055e88992c1c_0001'. Query: 'ALTER TABLE sys_user
  ADD COLUMN account_category varchar(10) DEFAULT NULL AFTER account_manager'
1146	Worker 1 failed executing transaction 'ANONYMOUS' at master log mysql-bin.000050, end_log_pos 546322173; Error 'Table 'g1_c0a44cb3574547b49669f8ca6a645924_0001.search_voucher' doesn't exist' on query. Default database: 'g1_c0a44cb3574547b49669f8ca6a645924_0001'. Query: 'truncate `search_voucher`'
1008	Worker 1 failed executing transaction 'ANONYMOUS' at master log mysql-bin.000050, end_log_pos 567430678; Error 'Can't drop database 'g1_780225ac88f0434ab888c4c1f1b3a170_0001'; database doesn't exist' on query. Default database: 'g1_780225ac88f0434ab888c4c1f1b3a170_0001'. Query: 'DROP DATABASE `g1_780225ac88f0434ab888c4c1f1b3a170_0001`'

