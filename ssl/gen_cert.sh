#! /bin/sh

show_help() {
    echo "Usage: $0 org_name domain_name"
}

if [ $# -ne 2 ]
then
    show_help
    exit 1
fi

ORG=$1
DOMAIN=$2

if [ $ORG = "" ]
then
    show_help
    exit 1
fi

CA_DIR="./root_ca/${ORG}"

if [ ! -d $CA_DIR ]
then
    echo "root ca not found please input currect root ca or generate new with gen_root.sh"
    read -p "Do you want to create a new one? [y, n] : " create_root
    if [ $create_root = 'y' ]
    then
        bash ./gen_root.sh $ORG
    else    
        exit 1
    fi
fi

OUTPUT_DIR="./cert/${ORG}/${DOMAIN}"

if [ ! -d $OUTPUT_DIR ]
then
  mkdir -p $OUTPUT_DIR
fi


# Generate Private key 
openssl genrsa -out ${OUTPUT_DIR}/${DOMAIN}.key 2048

# Create csf conf
cat > ${OUTPUT_DIR}/csr.conf <<EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C = US
ST = California
L = San Fransisco
O = ${ORG}
OU = Develop
CN = ${DOMAIN}

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = ${DOMAIN}
IP.1 = 127.0.0.1

EOF


# create CSR request using private key
openssl req -new -key ${OUTPUT_DIR}/${DOMAIN}.key -out ${OUTPUT_DIR}/${DOMAIN}.csr -config ${OUTPUT_DIR}/csr.conf

# Create a external config file for the certificate
cat > ${OUTPUT_DIR}/cert.conf <<EOF

authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${DOMAIN}

EOF

# Create SSl with self signed CA
openssl x509 -req \
    -in ${OUTPUT_DIR}/${DOMAIN}.csr \
    -CA ${CA_DIR}/rootCA.crt -CAkey ${CA_DIR}/rootCA.key \
    -CAcreateserial -out ${OUTPUT_DIR}/${DOMAIN}.crt \
    -days 365 \
    -sha256 -extfile ${OUTPUT_DIR}/cert.conf

cat ${OUTPUT_DIR}/${DOMAIN}.crt ${CA_DIR}/rootCA.crt > ${OUTPUT_DIR}/fullchain.pem
