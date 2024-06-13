#!/bin/bash

INPUT_CONFIG=input.config
OUTPUT_FOLDER=output

rm $OUTPUT_FOLDER/*
./InvoiceDownloader.sh $INPUT_CONFIG $OUTPUT_FOLDER > >(tee -a log/output.log) 2> >(tee -a log/output.error >&2)
./InvoiceMailer.sh $OUTPUT_FOLDER > >(tee -a log/output.log) 2> >(tee -a log/output.error >&2)
