#!/bin/bash

# 百望云
INVOICE_URL_KEY="http://i.baiwang.com/kaipiao/previewInvoice?invoiceId={invoice_id}"
INVOICE_URL_FORWARD="http://i.baiwang.com/api/forward/tour/invoices?invoiceId={invoice_id}"

get_download_url() {
    pattern=$(sed 's/\([?\/]\)/\\\1/g' <<< "${INVOICE_URL_KEY//\{invoice_id\}/(.+)}")
    if [[ ! $1 =~ $pattern ]]; then
        echo "$BASH_SOURCE: no matching URL found: $1"
        return 1
    fi
    
    invoice_id="${BASH_REMATCH[1]}"
    forward_url="${INVOICE_URL_FORWARD//\{invoice_id\}/$invoice_id}"
    result=$(curl -s "$forward_url" | jq -r '.resultData[0].einvoiceUrl')

    if [[ $? -ne 0 || "$result" == null ]]; then
        echo "Error: Failed to get download_url from $forward_url" >&2
        return 1
    fi

    echo "$result"
    return 0
}
