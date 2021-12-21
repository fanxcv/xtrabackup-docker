#!/bin/bash
echo "HAS_FALL_BACK=" > /.backTemp
cd `dirname $0`
. ./common.sh

check_has_other_task

# 输出备份信息
echo `date_time`"start exec full back script"

# 压缩上传前一天的备份
echo `date_time`"compress the backup data of the last time"
cd $BASE_DIR
tar -zcf $YESTERDAY.tar.gz ./full/ ./incr/
# 如果设置了备份语句，执行备份语句
if [ -n "$BACKUP_SCRIPTS" ];then
  echo `date_time`"start exec backup script: $BACKUP_SCRIPTS"
  bash -c "$BACKUP_SCRIPTS"
  if [ $? = 0 ];then
    echo `date_time`"exec backup script success"
  else
    echo `date_time`"exec backup script failed"
  fi
fi
# scp -P 8022 $YESTERDAY.tar.gz root@192.168.10.46:/data/backup/mysql/
rm -rf $FULLBACKUPDIR $INCRBACKUPDIR
echo `date_time`"start exec $INNOBACKUPEXFULL $OPTION $FULLBACKUPDIR > $TMPFILE 2>&1"
$INNOBACKUPEXFULL $OPTION $FULLBACKUPDIR > $TMPFILE 2>&1

if [ -z "`tail -1 $TMPFILE | grep 'completed OK!'`" ];then
 echo "$INNOBACKUPEXFULL failed:"; echo
 echo "---------- ERROR OUTPUT from $INNOBACKUPEXFULL ----------"
 cat $TMPFILE
 rm -f $TMPFILE
 error "backup data failed"
fi

# 这里获取这次备份的目录
THISBACKUP=`awk -- "/Backup created in directory/ { split( \\\$0, p, \"'\" ) ; print p[2] }" $TMPFILE`
echo "THISBACKUP=$THISBACKUP"
rm -f $TMPFILE
echo
echo "Databases backed up successfully to: $THISBACKUP"

# Cleanup
echo "delete tar files of 10 days ago"
find $BASE_DIR/ -mtime +10 -name "*.tar.gz"  -exec rm -rf {} \;

echo
echo "completed: `date '+%Y-%m-%d %H:%M:%S'`"
echo "HAS_FALL_BACK=true" > /.backTemp
echo '' > ~/.run
exit 0
