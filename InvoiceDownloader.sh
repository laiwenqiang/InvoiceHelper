#!/bin/bash

readonly INPUT_URL=$1
readonly OUTPUT_FOLDER=$2

format_pdf_name() {
    # convert pdf to txt
    pdftotext -layout "$1" "$1.txt" || { echo "Failed to convert PDF to text: $1" >&2; return 1; }

    date=$(grep "开票日期" "$1.txt" | awk -F'：|:' '{print $2}')
    code=$(grep "发票号码" "$1.txt" | awk -F'：|:' '{print $2}')
    amount=$(grep "价税合计" "$1.txt" | awk -F'¥' '{print $2}')
    format_name="$(sed 's/ //g' <<< "$date-$code-$amount").pdf"

    mv "$1" "$OUTPUT_FOLDER/$format_name"
    rm "$1.txt"
}

get_download_url_from_plugin() {
    for plugin in plugins/*.sh; do
        source "$plugin"
        result=$(get_download_url $INPUT_URL)
        if [[ $? -eq 0 ]]; then
            echo "$result"
            return 0
        fi
    done

    echo "Can't find download_url in any plugins"
    return 1
}

download() {
    wget "$1" -O "$2" || { echo "Failed to download $1"; return 1; }
}

main() {
    download_url=$(get_download_url_from_plugin)
    if [[ $? -ne 0 ]]; then
        echo "$download_url"
        return 1
    fi

    output_pdf="$OUTPUT_FOLDER/${INPUT_URL:(-10):10}.pdf"
    download $download_url $output_pdf
    format_pdf_name "$output_pdf"
}

main