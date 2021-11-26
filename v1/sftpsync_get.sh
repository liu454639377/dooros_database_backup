#/bin/bash
rpm -aq | grep lftp
if [ $? -eq 1 ]; then
  yum install -y lftp
fi
#sftp服务器地址
HOST=xxx.xxx.xxx.xxx
#sftp服务器端口
PORT=9012
#sftp服务器账号
USERNAME="ftpsync"
#sftp服务器密码
PASSWORD="xxx.xxxxxx"
#本地目录
dir="/dooros_database_backup"
#目标文件
targets[0]="hkt.a.db."$(date +"%Y%m%d")".tar.gz"
targets[1]="hkt.b.db."$(date +"%Y%m%d")".tar.gz"
targets[2]="hkt.c.db."$(date +"%Y%m%d")".tar.gz"
targets[3]="hkt.d.db."$(date +"%Y%m%d")".tar.gz"

if [ ! -d $dir ]; then
  mkdir -p $dir
fi

for ((i = 0; i < 4; i++)); do
  lftp -u $USERNAME,$PASSWORD sftp://$HOST:$PORT <<EOF
  cd /doorosbackup
  lcd $dir  
  mget  ${targets[i]}
  bye 
EOF
done
#调用数据库检查脚本
/usr/bin/sh /dooros_database_backup/check_database.sh ${targets[*]}
