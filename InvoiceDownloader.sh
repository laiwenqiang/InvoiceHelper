#!/bin/bash

source ./logger.sh

readonly INPUT_URL=$1
readonly OUTPUT_FOLDER=$2
readonly OUTPUT_PDF="$OUTPUT_FOLDER/${INPUT_URL:(-10):10}.pdf"

DOWNLOAD_URL

format_pdf_name() {
    # convert pdf to txt
    pdftotext -layout "$OUTPUT_PDF" "$OUTPUT_PDF.txt" || { log_error "Failed to convert PDF to text: $OUTPUT_PDF" >&2; return 1; }

    date=$(grep "开票日期" "$OUTPUT_PDF.txt" | awk -F'：|:' '{print $2}')
    code=$(grep "发票号码" "$OUTPUT_PDF.txt" | awk -F'：|:' '{print $2}')
    amount=$(grep "价税合计" "$OUTPUT_PDF.txt" | awk -F'¥' '{print $2}')
    format_name="$(sed 's/ //g' <<< "$date-$code-$amount").pdf"

    mv "$OUTPUT_PDF" "$OUTPUT_FOLDER/$format_name"
    rm "$OUTPUT_PDF.txt"
}

get_download_url_from_plugin() {
    for plugin in plugins/*.sh; do
        source "$plugin"
        result=$(get_download_url $INPUT_URL)
        if [[ $? -eq 0 ]]; then
            DOWNLOAD_URL=$result
            log_info "Find download_url in $plugin: $INPUT_URL"
            return 0
        fi
    done

    log_error "Can't find download_url in any plugins: $INPUT_URL"
    return 1
}

download() {
    wget "$DOWNLOAD_URL" -O "$OUTPUT_PDF"
    if [[ $? -ne 0 ]]; then
        log_error "Failed to download $DOWNLOAD_URL"
        return 1
    fi

    log_info "Succeed download $DOWNLOAD_URL"
    return 0
}

main() {
    get_download_url_from_plugin || { return 1; }
    download || { return 1; }
    format_pdf_name || { return 1; }
}

main