#!/bin/bash

INVOICE_FOLDER=$1
MAIL_ATTACH="发票附件.tar"
MAIL_CONTENT=""

check_invoice_folder() {
    if [ -z "$INVOICE_FOLDER" ]; then
        echo "Error: No directory supplies"
        exit 1
    fi

    if [ ! -d "$INVOICE_FOLDER" ]; then
        echo "Error: $INVOICE_FOLDER is not a directory"
        exit 1
    fi

    if [ -z "$(ls "$INVOICE_FOLDER")" ]; then
        echo "Error: $INVOICE_FOLDER is an empty directory"
        exit 1
    fi
}

gen_mail_content() {
    tar czf "$MAIL_ATTACH" -C "$INVOICE_FOLDER" . && mv "$MAIL_ATTACH" "$INVOICE_FOLDER/"
    MAIL_CONTENT=$(ls "$INVOICE_FOLDER"/*pdf | xargs -n 1 basename | awk '{print NR". "$0}')
}

send_mail() {
    echo "$MAIL_CONTENT" | mutt -a "$INVOICE_FOLDER/$MAIL_ATTACH" -s "InvoiceHelper Result" -- 1260091093@qq.com

    if [ $? -eq 0 ]; then
        echo -e "Mail sent successfully, content: \n$MAIL_CONTENT"
    else
        echo -e "Failed to send mail, content: \n$MAIL_CONTENT"
        exit 1
    fi
}

main() {
    check_invoice_folder
    gen_mail_content
    send_mail
}

main $1