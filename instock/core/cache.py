#!/usr/bin/env python
# -*- coding:utf-8 -*-

import json
from datetime import datetime, date
from functools import wraps

import pandas as pd
import redis

# Redis连接配置
REDIS_CONFIG = {
    'host': 'localhost',
    'port': 6379,
    'db': 1,
    'decode_responses': True
}

# 缓存时间（秒），默认为1天
CACHE_EXPIRE_TIME = 3600

# 创建Redis连接池
redis_pool = redis.ConnectionPool(**REDIS_CONFIG)
redis_client = redis.Redis(connection_pool=redis_pool)


def datetime_to_str(obj):
    """处理datetime和date类型的序列化"""
    if isinstance(obj, (datetime, date, pd.Timestamp)):
        return obj.isoformat()
    raise TypeError(f"Type {type(obj)} not serializable")

def redis_cache(func):
    """
    Redis缓存装饰器
    """
    @wraps(func)
    def wrapper(*args, **kwargs):
        # 生成缓存键
        func_name = func.__name__
        cache_key = f"stock_data:{func_name}:"

        # 处理位置参数
        for arg in args:
            cache_key += f"{arg}:"

        # 处理关键字参数
        for k, v in sorted(kwargs.items()):
            cache_key += f"{k}={v}:"

        # 移除末尾的冒号
        if cache_key.endswith(':'):
            cache_key = cache_key[:-1]

        # 尝试从缓存获取数据
        cached_data = redis_client.get(cache_key)

        if cached_data is not None:
            try:
                # 尝试解析JSON数据
                data_dict = json.loads(cached_data)

                # 如果是DataFrame，需要重新构建
                if data_dict.get('_is_dataframe', False):
                    df = pd.DataFrame(data_dict['data'])
                    # 恢复日期类型列
                    for col in data_dict.get('date_columns', []):
                        if col in df.columns:
                            df[col] = pd.to_datetime(df[col])
                    return df
                else:
                    return data_dict['data']
            except Exception as e:
                print(f"从缓存加载数据失败: {e}，将重新获取数据")

        # 缓存未命中或解析失败，执行原函数
        result = func(*args, **kwargs)

        # 将结果存入缓存
        try:
            if isinstance(result, pd.DataFrame):
                # 处理DataFrame
                data_dict = {
                    '_is_dataframe': True,
                    'data': result.to_dict(orient='records'),
                    'date_columns': [col for col in result.columns
                                     if pd.api.types.is_datetime64_any_dtype(result[col])]
                }
                # 使用自定义序列化函数处理datetime类型
                redis_client.setex(cache_key, CACHE_EXPIRE_TIME, json.dumps(data_dict, default=datetime_to_str))
            else:
                # 处理其他类型
                data_dict = {
                    '_is_dataframe': False,
                    'data': result
                }
                # 使用自定义序列化函数处理datetime类型
                redis_client.setex(cache_key, CACHE_EXPIRE_TIME, json.dumps(data_dict, default=datetime_to_str))
        except Exception as e:
            print(f"缓存数据失败: {e}")

        return result

    return wrapper