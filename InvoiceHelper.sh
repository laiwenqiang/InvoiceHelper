#!/bin/bash

source ./logger.sh

INPUT_CONFIG=input.config
OUTPUT_FOLDER=output


main() {
    rm $OUTPUT_FOLDER/*

    while IFS= read -r url
    do
    if [[ $url != \#* ]]; then
            log_info "Begin to download invoice with reference: $url"
            ./InvoiceDownloader.sh $url $OUTPUT_FOLDER
    fi
    done < $INPUT_CONFIG

    log_info "Begin to mail..."
    ./InvoiceMailer.sh $OUTPUT_FOLDER
}

main
