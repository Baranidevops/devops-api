#!/usr/bin/env bash

# Specify where we will install
# the xip.io certificate
SSL_DIR="/etc/httpd/certificates"

# Set the wildcarded domain
# we want to use
DOMAIN="localhost"

# A blank passphrase
PASSPHRASE=""

# Set our CSR variables
SUBJ="
C=US
ST=MN
O=Dis
localityName=Minneapolis
commonName=$DOMAIN
organizationalUnitName=
emailAddress=
"

# Create our SSL directory
# in case it doesn't exist
sudo mkdir -p "$SSL_DIR"

# Generate our Private Key, CSR and Certificate
sudo openssl genrsa -out "$SSL_DIR/adaptive-apache.key" 2048
sudo openssl req -new -subj "$(echo -n "$SUBJ" | tr "\n" "/")" -key "$SSL_DIR/adaptive-apache.key" -out "$SSL_DIR/adaptive-apache.csr" -passin pass:$PASSPHRASE
sudo openssl x509 -req -days 365 -in "$SSL_DIR/adaptive-apache.csr" -signkey "$SSL_DIR/adaptive-apache.key" -out "$SSL_DIR/adaptive-apache.crt"
