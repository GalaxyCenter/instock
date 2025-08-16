#!/bin/bash

# 检查是否传入参数，如果没有，默认使用当天日期
if [ -z "$1" ]; then
    DATE=$(date +%Y-%m-%d)
else
    DATE=$1
fi

echo "使用日期: $DATE"

cd ..
cd job

# 执行所有 Python 脚本，并传入日期参数
python backtest_data_daily_job.py "$DATE"
#基础数据收盘2小时后作业
python basic_data_after_close_daily_job.py "$DATE"
#基础数据实时作业(早盘强筹数据\每日ETF数据)
python basic_data_daily_job.py "$DATE"
#基础数据非实时作业
python basic_data_other_daily_job.py "$DATE"
#指标数据作业
python indicators_data_daily_job.py "$DATE"
#K线形态作业
python klinepattern_data_daily_job.py "$DATE"
#综合选股作业
python selection_data_daily_job.py "$DATE"
#策略数据作业
python strategy_data_daily_job.py "$DATE"

echo "所有任务执行完成。"