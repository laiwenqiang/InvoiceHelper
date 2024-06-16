#!/bin/bash

# 定义键值对数组
INVOICE_URL_KEYS=(
    # 票通
    "https://scan.vpiaotong.com/#/invoiceStatus/{invoice_id}?sbyy="
    "https://fpkj.vpiaotong.com/tp/scan-invoice/view/{invoice_id}.pt"
    "https://scan.vpiaotong.com/#/boardFile?lsh={invoice_id}"
    "https://fpkj.vpiaotong.com/tp/s/v/{invoice_id}.pt"
)

INVOICE_URL_VALUES=(
    "https://scan.vpiaotong.com/Aloe/tp/scan-invoice/getElectronicInvoice.pt?lsh={invoice_id}&fileType=PDF"
    "https://scan.vpiaotong.com/Aloe/tp/scan-invoice/getElectronicInvoice.pt?lsh={invoice_id}&fileType=PDF"
    "https://scan.vpiaotong.com/Aloe/tp/scan-invoice/getElectronicInvoice.pt?lsh={invoice_id}&fileType=PDF"
    "https://scan.vpiaotong.com/Aloe/tp/scan-invoice/getElectronicInvoice.pt?lsh={invoice_id}&fileType=PDF"
)

get_download_url() {
    # 匹配输入URL并替换值
    for i in "${!INVOICE_URL_KEYS[@]}"; do
        key="${INVOICE_URL_KEYS[$i]}"
        value="${INVOICE_URL_VALUES[$i]}"

        # 提取占位符中的值
        pattern=$(sed 's/\([?\/]\)/\\\1/g' <<< "${key//\{invoice_id\}/(.+)}")
        if [[ $1 =~ $pattern ]]; then
            invoice_id="${BASH_REMATCH[1]}"
            result="${value//\{invoice_id\}/$invoice_id}"
            echo "$result"
            return 0
        fi
    done

    echo "$BASH_SOURCE: no matching URL found: $1"
    return 1
}