#! /bin/bash

if [ "$#" -ne 1 ]
then
  echo "Error: No domain name argument provided"
  echo "Usage: Provide a domain name as an argument"
  exit 1
fi

DOMAIN=$1

if [ ! -d $DOMAIN ]
then
  mkdir $DOMAIN
fi

# Create root CA & Private key

openssl req -x509 \
            -sha256 -days 356 \
            -nodes \
            -newkey rsa:2048 \
            -subj "/CN=${DOMAIN}/C=US/L=San Fransisco" \
            -keyout ./${DOMAIN}/rootCA.key -out ./${DOMAIN}/rootCA.crt 

# Generate Private key 

openssl genrsa -out ./${DOMAIN}/${DOMAIN}.key 2048

# Create csf conf

cat > ./${DOMAIN}/csr.conf <<EOF
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
O = MLopsHub
OU = MlopsHub Dev
CN = ${DOMAIN}

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = ${DOMAIN}
IP.1 = 192.168.11.51

EOF

# create CSR request using private key

openssl req -new -key ./${DOMAIN}/${DOMAIN}.key -out ./${DOMAIN}/${DOMAIN}.csr -config ./${DOMAIN}/csr.conf

# Create a external config file for the certificate

cat > ./${DOMAIN}/cert.conf <<EOF

authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${DOMAIN}

EOF

# Create SSl with self signed CA

openssl x509 -req \
    -in ./${DOMAIN}/${DOMAIN}.csr \
    -CA ./${DOMAIN}/rootCA.crt -CAkey ./${DOMAIN}/rootCA.key \
    -CAcreateserial -out ./${DOMAIN}/${DOMAIN}.crt \
    -days 365 \
    -sha256 -extfile ./${DOMAIN}/cert.conf

cat ./${DOMAIN}/${DOMAIN}.crt ./${DOMAIN}/rootCA.crt > ./${DOMAIN}/fullchain.pem