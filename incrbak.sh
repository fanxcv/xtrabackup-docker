#!/bin/bash
cd `dirname $0`
. ./common.sh

if [ -f /.backTemp ];then
  . /.backTemp
fi

if [ ! $HAS_FALL_BACK ]; then
  error "未全量备份，跳过本次增量备份"
fi

# 输出备份信息
echo `date_time`"start exec incr back script"

# 查找最近的全备目录
LATEST_FULL=`find $FULLBACKUPDIR -mindepth 1 -maxdepth 1 -type d -printf "%P\n"`
echo `date_time`"最近的全备目录为: $LATEST_FULL"

# 如果最近的全备仍然可用执行增量备份
# 创建增量备份的目录
TMPINCRDIR=$INCRBACKUPDIR/$LATEST_FULL
mkdir -p $TMPINCRDIR
BACKTYPE="incr"
# 获取最近的增量备份目录
LATEST_INCR=`find $TMPINCRDIR -mindepth 1 -maxdepth 1 -type d | sort -nr | head -1`
echo "最近的增量备份目录为: $LATEST_INCR"
# 如果是首次增量备份，那么basedir则选择全备目录，否则选择最近一次的增量备份目录
if [ ! $LATEST_INCR ] ; then
  INCRBASEDIR=$FULLBACKUPDIR/$LATEST_FULL
else
  INCRBASEDIR=$LATEST_INCR
fi
echo "Running new incremental backup using $INCRBASEDIR as base."
echo "start exec $INNOBACKUPEXFULL $OPTION --incremental $TMPINCRDIR --incremental-basedir $INCRBASEDIR > $TMPFILE 2>&1"
$INNOBACKUPEXFULL $OPTION --incremental $TMPINCRDIR --incremental-basedir $INCRBASEDIR > $TMPFILE 2>&1

if [ -z "`tail -1 $TMPFILE | grep 'completed OK!'`" ] ; then
 echo "$INNOBACKUPEX failed:"; echo
 echo "---------- ERROR OUTPUT from $INNOBACKUPEX ----------"
 error "incr backup faild"
fi

# 这里获取这次备份的目录
THISBACKUP=`awk -- "/Backup created in directory/ { split( \\\$0, p, \"'\" ) ; print p[2] }" $TMPFILE`
echo "THISBACKUP=$THISBACKUP"
rm -f $TMPFILE
echo
echo "Databases backed up successfully to: $THISBACKUP"

echo
echo "incremental completed: `date '+%Y-%m-%d %H:%M:%S'`"
exit 0
