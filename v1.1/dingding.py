#!/usr/bin/python3
# -*- coding: utf-8 -*-

import requests
import json
import sys
import os

headers = {'Content-Type': 'application/json;charset=utf-8'}
api_url = "https://oapi.dingtalk.com/robot/send?access_token=c194eab8c95e7759e725c58d680f70e4d47674ca34838258bde315b052fd1005"
#api_url="https://oapi.dingtalk.com/robot/send?access_token=9c167ef84b00143ec2c02709ba060eeb644df70d72f3b5e66812d00b6f14c409"
#定义报警函数
def msg(text):
    json_text= {
     "msgtype": "markdown",
        "markdown": {
            "title":"钉钉机器人报警",
            "text": text+ 
                   "@18820267422",
        },
        "at": {
            "atMobiles":[
                "18820267422",#刘环
#               "15982112742",#冯艺
            ],
            "isAtAll": False,
        }
    }
    print (requests.post(api_url,json.dumps(json_text),headers=headers).content)

#检差导入数据库查询结果，过滤后通知
def check(tmpname):
    check=os.popen("egrep -e 'error_flag' /dooros_database_backup/"+tmpname)
    os.popen("rm -rf /dooros_database_backup/"+tmpname)
    print(check.read())
    if  not check.read():
       return "  数据库正常" 
    else:
       return " 数据库异常,"+check.read()
    
if __name__ == '__main__':
    for i in sys.argv[1:]:
        if os.path.exists("/dooros_database_backup/"+i):
            msg(i+check(i+".tmp"))
            os.popen("rm -rf /dooros_database_backup/"+i)
    os.popen("rm -rf /dooros_database_backup/tables.txt")#删除临时数据库表名文件
    os.popen("rm -rf /dooros_database_backup/dooros.sql")#删除临时数据库文件
