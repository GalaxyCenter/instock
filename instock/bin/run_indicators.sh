#!/bin/bash

# 设置开始和结束日期
start_date="2025-05-26"
end_date="2025-06-02"

# 将日期转为时间戳以便比较
current=$(date -d "$start_date" +%s)
end=$(date -d "$end_date" +%s)

# 循环执行直到 current > end
while [ $current -le $end ]; do
    # 格式化当前日期为 YYYY-MM-DD
    current_date=$(date -d "@$current" +"%Y-%m-%d")

    echo "Running job for date: $current_date"
    python /d/WorkSpaces/Python/instock/instock/job/indicators_data_daily_job.py $current_date

    # 检查上一条命令是否成功（可选）
    if [ $? -ne 0 ]; then
        echo "Error occurred when running script for $current_date"
        exit 1
    fi

    # 增加一天（86400 秒）
    current=$((current + 86400))
done