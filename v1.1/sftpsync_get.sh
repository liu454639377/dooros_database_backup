#/bin/bash
rpm -aq | grep lftp
if [ $? -eq 1 ]; then
    yum install -y lftp
fi
#sftp服务器地址
HOST=117.176.240.253
#sftp服务器端口
PORT=9012
#sftp服务器账号
USERNAME="ftpsync"
#sftp服务器密码
PASSWORD="goodluck@123."
#本地目录
dir="/dooros_database_backup"
#目标文件
targets[0]="hkt.a.db."`date +"%Y%m%d"`".tar.gz"
targets[1]="hkt.b.db."`date +"%Y%m%d"`".tar.gz"
targets[2]="hkt.c.db."`date +"%Y%m%d"`".tar.gz"
targets[3]="hkt.d.db."`date +"%Y%m%d"`".tar.gz"
#如果不存在则创建工作目录
if [ ! -d $dir ] ;then 
mkdir -p $dir
fi
#从nas循环拉取数据库
for i in ${targets[@]} ;  
do  
echo $i
#拉取动作
lftp -u $USERNAME,$PASSWORD sftp://$HOST:$PORT <<EOF
  cd /doorosbackup
  lcd $dir  
  mget $i
  bye 
EOF
done
#调用数据库检查脚本
/usr/bin/sh -x /dooros_database_backup/check_database.sh ${targets[*]}
