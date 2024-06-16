#!/bin/bash

# 定义键值对数组
INVOICE_URL_KEYS=(
    # 51发票
    "https://dlj.51fapiao.cn/dlj/v7/{invoice_id}"
    "https://xz.bwfapiao.com/qdp/{invoice_id}"
)

get_download_url() {
    # 匹配输入URL并替换值
    for i in "${!INVOICE_URL_KEYS[@]}"; do
        key="${INVOICE_URL_KEYS[$i]}"

        # 提取占位符中的值
        pattern=$(sed 's/\([?\/]\)/\\\1/g' <<< "${key//\{invoice_id\}/(.+)}")
        if [[ $1 =~ $pattern ]]; then
            echo "$1"
            return 0
        fi
    done

    echo "$BASH_SOURCE: no matching URL found: $1"
    return 1
}