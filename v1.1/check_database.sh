#!/bin/bash
#定义备份目录
dir="/dooros_database_backup"
#文件名
filename=$@
#解压文件
#mysql账号
mysql_user="dooros"
#mysql密码
mysql_pass="dooros"
#mysql主机
mysql_host="172.11.0.2"
#临时数据库表名
tmp_file=tables.txt


#循环遍历数据库文件
for i in $filename; do
    if [ -f /dooros_database_backup/$i ]; then
    #解压文件
    tar -zxvf $i 
    #重新创建一个新的mysql容器
    cd /root/mysqldb && docker-compose down
    rm -rf data
    docker-compose up -d
    #保证新建的mysql容器正常工作，延迟20秒
    sleep 20
    #回到工作目录
    cd $dir
    #定义sql登录执行动作
    sql_db="mysql -h $mysql_host -P 3306 -u $mysql_user -p$mysql_pass dooros -e"
    #导入数据库
    $sql_db "source $dir/dooros.sql"
    #先查询一下所有dooros的表名
    $sql_db "show tables;">$tmp_file
    #删除查询的表头脏数据
    sed -i "1d" $tmp_file 

    #提取每一行表名，进行遍历查询里面的数据，如果表为空，就重新根据描述解释这个表结构是否完整
    while read line ; 
    do 
        $sql_db "SELECT * FROM $line ORDER BY RAND() LIMIT 1" > /tmp/checksql.tmp 
        tmp=`cat /tmp/checksql.tmp | wc -l`
        rm -rf /tmp/checksql.tmp
            if [ $tmp -eq 2 ];#正常查询有两个结果
            then
                echo "$line table is complete_flag" >> $dir/$i.tmp
                #如果查询表里面的数据为空，则查询表结构是否完整
            elif [ $tmp -eq 0 ];
            then
                $sql_db "desc $line" > /tmp/checksql_desc.tmp
                tmp_desc=`cat /tmp/checksql_desc.tmp | wc -l`
                rm -rf /tmp/checksql_desc.tmp
                if [ ! $tmp_desc -eq 0 ]; 
                then
                    #查询表结构不为空，输出完整
                    echo "$line table is complete_flag" >> $dir/$i.tmp
                else
                    #查询表结构为空，则输出错误
                    echo "$line table is error_flag" >> $dir/$i.tmp  
                fi
            else
                #查询错误则输出错误结果
                echo "$line table is error_flag" >> $dir/$i.tmp
            fi
    done <$tmp_file
else
    echo "文件不存在"
 
fi

done

#执行检查数据库结果过滤，通知报警
/usr/bin/python3 dingding.py $filename

