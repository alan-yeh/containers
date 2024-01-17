#!/bin/sh

# 脚本执行失败时脚本终止执行
set -o errexit
# 遇到未声明变量时脚本终止执行
set -o nounset
# 执行管道命令时，只要有一个子命令失败，则脚本终止执行
set -o pipefail
# 打印执行过程，主要用于调试
#set -o xtrace

#===========================================================================================
# TimeZone Configuration
#===========================================================================================
if [ -n "$TZ" ]; then
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
fi

#===========================================================================================
# Script
#===========================================================================================
case "$1" in
    time)
        echo -e "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ \033[35m$(date +"%Y-%m-%d %H:%M:%S")\033[0m ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "┃ Wait $2 seconds"
        echo "┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        for i in $(seq 1 $2)
        do
            echo "┃ 💗 Remaining $(($2 - $i)) seconds..."
            sleep 1
        done
        echo "┃ ✅ Time's up!"
        echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        exit 0
    ;;
    tcp|udp)
        protocol=$(echo $1 | tr '[:lower:]' '[:upper:]')
        if [ "$1" == "UDP" ]; then
            protocol="UDP"
        else
            protocol="TCP"
        fi
        echo -e "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ \033[35m$(date +"%Y-%m-%d %H:%M:%S")\033[0m ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "┃ Wait for $protocol $2:$3"
        echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        while [ 1 ]; do

            # 输出命令信息
            echo ""
            echo -e "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ \033[35m$(date +"%Y-%m-%d %H:%M:%S")\033[0m ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

            # 执行命令
            set +o errexit

            # 没办法捕捉 nc 输出的日志，有点坑爹
            if [ "$protocol" == "TCP" ]; then
                echo "┃ \$ nc -zv $2 $3"
                nc -zv $2 $3
            else
                echo "┃ \$ nc -uzv $2 $3"
                nc -uzv $2 $3
            fi

            status=$?
            set -o errexit

            echo "┃"
            # 检查返回的状态码
            if [ "$status" == "0" ]; then
                echo "┃ ✅ Socket connect succeeded"
                echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                exit 0
            else
                echo "┃ ❌ Socket connect failed"
                echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                sleep 2
            fi
        done
        exit 0
    ;;
    lookup)
        echo -e "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ \033[35m$(date +"%Y-%m-%d %H:%M:%S")\033[0m ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "┃ Wait for lookup '$2'"
        echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        while [ 1 ]; do
            # 执行命令
            set +o errexit
            output=$(nslookup $2)
            status=$?
            set -o errexit

            # 输出命令信息
            echo ""
            echo -e "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ \033[35m$(date +"%Y-%m-%d %H:%M:%S")\033[0m ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "┃ \$ nslookup $2"
            echo "$output" | awk -v prefix="┃ " '{print prefix $0}'
            echo "┃"

            # 检查返回的状态码
            if [ "$status" == "0" ]; then
                echo "┃ ✅ Service Found"
                echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                exit 0
            else
                echo "┃ ❌ Service Not Found"
                echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                sleep 2
            fi
        done
        exit 0
    ;;
    get)
        echo -e "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ \033[35m$(date +"%Y-%m-%d %H:%M:%S")\033[0m ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "┃ Wait for 'GET $2'"
        echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        while [ 1 ]; do
            # 发送 curl 请求，设置超时时间为 5 秒
            set +o errexit
            response=$(curl -s -m 5 -o /dev/null -w "%{http_code}" "$2")
            set -o errexit

            # 输出命令信息
            echo ""
            echo -e "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ \033[35m$(date +"%Y-%m-%d %H:%M:%S")\033[0m ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "┃ \$ curl -s -m 5 -o /dev/null -w %{http_code} $2"
            echo "┃"

            # 检查返回的状态码
            if [ "$response" == "200" ]; then
                echo "┃ ✅ Response Status: 200"
                echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                exit 0
            elif [ "$response" == "000" ]; then
                echo "┃ ❌ Response Timeout"
                echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                sleep 2
            elif [ "$response" == "7" ]; then
                echo "┃ ❌ Server Not Reachable"
                echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                sleep 2
            else
                echo "┃ ❌ Response Status: $response"
                echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                sleep 2
            fi
        done
    ;;
    cmd)
        shift
        echo -e "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ \033[35m$(date +"%Y-%m-%d %H:%M:%S")\033[0m ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "┃ Wait for command '$@'"
        echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        while [ 1 ]; do
            # 执行命令
            set +o errexit
            output=$($@)
            status=$?
            set -o errexit

            # 输出命令信息
            echo ""
            echo -e "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ \033[35m$(date +"%Y-%m-%d %H:%M:%S")\033[0m ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "┃ \$ $@"
            echo "$output" | awk -v prefix="┃ " '{print prefix $0}'
            echo "┃"

            # 检查返回的状态码
            if [ "$status" == "0" ]; then
                echo "┃ ✅ Exit Status: 0"
                echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                exit 0
            else
                echo "┃ ❌ Exit Status: $status"
                echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                sleep 2
            fi
        done
    ;;
    *)
        echo "Unsupported command '$1'"
        exit 1
esac