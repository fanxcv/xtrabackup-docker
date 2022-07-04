#!/usr/bin/env bash
# 如果用户未设置BASE_DIR，备份会保存在VOLUME中，防止备份丢失
if [ "$BASE_DIR" = "" ]; then
  export BASE_DIR=/data
fi

# 将环境变量写入到文件中，方便定时任务在执行时获取，要不定时任务获取不到Docker设置的环境变量
echo "export BACKUP_SCRIPTS='$BACKUP_SCRIPTS'" > /dockerenv
echo "export BASE_DIR='$BASE_DIR'" >> /dockerenv
echo "export OPTION='$OPTION'" >> /dockerenv
if [ "$1" == "init" ];then
    # 初始化执行环境
    /etc/init.d/cron start
    echo '0 3 * * 3,6 root /root/fullbak.sh > /var/log/mysql_backup.log 2>&1' >> /etc/crontab
    echo '0 */2 * * * root /root/incrbak.sh >> /var/log/mysql_backup.log 2>&1' >> /etc/crontab
    /root/fullbak.sh > /var/log/mysql_backup.log 2>&1
    tail -f /var/log/mysql_backup.log
else
    # 透传待执行的命令
    exec "$@"
fi
