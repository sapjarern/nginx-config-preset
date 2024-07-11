#! /bin/sh

show_help() {
    echo "Usage: $0 org_name"
}

if [ $# -ne 1 ]
then
    show_help
    exit 1
fi

ORG=$1

if [ $ORG = "" ]
then
    show_help
    exit 1
fi

OUTPUT_DIR="./root_ca/${ORG}"

if [ ! -d $OUTPUT_DIR ]
then
  mkdir -p $OUTPUT_DIR
fi

openssl req -x509 \
            -sha256 -days 356 \
            -nodes \
            -newkey rsa:2048 \
            -subj "/CN=${ORG}/C=US/L=San Fransisco" \
            -keyout ${OUTPUT_DIR}/rootCA.key -out ${OUTPUT_DIR}/rootCA.crt

echo "output dir ${OUTPUT_DIR}"
