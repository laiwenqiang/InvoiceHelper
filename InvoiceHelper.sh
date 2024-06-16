#!/bin/bash

INPUT_CONFIG=input.config
OUTPUT_FOLDER=output

rm $OUTPUT_FOLDER/*

while IFS= read -r url
do
    if [[ $url != \#* ]]; then
            ./InvoiceDownloader.sh $url $OUTPUT_FOLDER > >(tee -a log/output.log) 2> >(tee -a log/output.error >&2)
    fi
done < $INPUT_CONFIG

./InvoiceMailer.sh $OUTPUT_FOLDER > >(tee -a log/output.log) 2> >(tee -a log/output.error >&2)
