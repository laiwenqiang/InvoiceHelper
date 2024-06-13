#!/bin/bash

# 定义键值对数组
INVOICE_URL_KEYS=(
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

get_download_info() {
    # 匹配输入URL并替换值
    for i in "${!INVOICE_URL_KEYS[@]}"; do
        key="${INVOICE_URL_KEYS[$i]}"
        value="${INVOICE_URL_VALUES[$i]}"

        # 提取占位符中的值
        pattern=$(sed 's/\([?\/]\)/\\\1/g' <<< "${key//\{invoice_id\}/(.+)}")
        if [[ $1 =~ $pattern ]]; then
            invoice_id="${BASH_REMATCH[1]}"
            output_url="${value//\{invoice_id\}/$invoice_id}"
            echo "$output_url $invoice_id"
            return 0
        fi
    done

    echo "No matching URL found: $1" >&2
    return 1
}

format_pdf_name() {
    ## convert pdf to txt
    pdftotext -layout "$1" "$1.txt" || { echo "Failed to convert PDF to text: $1" >&2; return 1; }

    date=$(grep "开票日期" "$output_pdf.txt" | awk -F'：' '{print $2}')
    code=$(grep "发票号码" "$output_pdf.txt" | awk -F'：' '{print $2}')
    amount=$(grep "价税合计" "$output_pdf.txt" | awk -F'¥' '{print $2}')
    format_name="$(sed 's/ //g' <<< "$date-$code-$amount").pdf"

    mv "$1" "$OUTPUT_FOLDER/$format_name"
    rm "$1.txt"
}

download() {
    IFS=' ' read -r download_url pdf_key <<< $(get_download_info $1)
    output_pdf="$OUTPUT_FOLDER/$pdf_key.pdf"

    echo "file: $output_pdf"

    wget "$download_url" -O "$output_pdf" || echo "Failed to download $download_url"
    format_pdf_name "$output_pdf"
}

main() {
    while IFS= read -r url 
    do
        download "$url"
    done < $INPUT_CONFIG
}

INPUT_CONFIG=$1
OUTPUT_FOLDER=$2
main