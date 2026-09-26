#!/bin/sh
# 容器启动入口: 启动时统一完成依赖与数据初始化, 然后拉起服务。
# 正常镜像构建阶段已安装依赖; 若以挂载源码/ requirements.txt 的方式运行且
# 检出缺失依赖, 这里做一次幂等补齐(已安装的包会被 pip 跳过), 保证
# `docker compose up --build` 单条命令即可启动, 无需手工初始化。
set -e

echo "[entrypoint] 检查/初始化 Python 依赖..."
pip install --no-cache-dir -r /app/requirements.txt

echo "[entrypoint] 初始化数据库(SQLite, 幂等建表)..."
BALANCER_DB="${BALANCER_DB:-/app/data/balancer.db}"
BALANCER_DB="$BALANCER_DB" python -c "from app.main import init_db; init_db()"

echo "[entrypoint] 启动 uvicorn(0.0.0.0:8000)..."
exec "$@"
