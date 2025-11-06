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
echo "基础数据实时作业(股票实时行情数据\每日ETF数据)"
python basic_data_daily_job.py "$DATE"
echo "综合选股作业(只有前一天的数据)"
python selection_data_daily_job.py "$DATE"
echo "股票基本数据(每日股票龙虎榜\基本面选股\每日股票分红配送\每日股票资金流向\每日行业资金流向(行业资金、概念资金)\每日早盘抢筹\每日涨停原因)"
python basic_data_other_daily_job.py "$DATE"
echo "指标数据作业"
python indicators_data_daily_job.py "$DATE"
echo "K线形态作业"
python klinepattern_data_daily_job.py "$DATE"
echo "策略数据作业"
python strategy_data_daily_job.py "$DATE"
echo "股票策略回归测试"
python backtest_data_daily_job.py "$DATE"
echo "每日股票大宗交易 每日尾盘抢筹"
python basic_data_after_close_daily_job.py "$DATE"

echo "所有任务执行完成。"