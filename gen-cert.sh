#!/bin/bash

# VPN Certificate Generation Script
# This script generates a Certificate Authority (CA) and client/server certificates for the VPN

set -e  # Exit on any error

echo "=== VPN Certificate Generation Script ==="
echo

# Function to prompt for certificate details
prompt_cert_details() {
    local cert_type=$1
    echo "Enter details for $cert_type certificate:"
    echo "You can press Enter to use default values shown in brackets"
    echo
}

# Create certificates directory if it doesn't exist
CERT_DIR="./certs"
mkdir -p "$CERT_DIR"
cd "$CERT_DIR"

echo "Creating certificates in directory: $(pwd)"
echo

# 1. Create CA private key
echo "Step 1/8: Generating Certificate Authority (CA) private key..."
openssl genrsa -out ca-key.pem 4096
echo "✓ CA private key created: ca-key.pem"
echo

# 2. Create CA certificate
echo "Step 2/8: Creating Certificate Authority (CA) certificate..."
prompt_cert_details "Certificate Authority"
openssl req -new -x509 -days 365 -key ca-key.pem -out ca-cert.pem \
    -subj "/C=US/ST=State/L=City/O=VPN-CA/OU=Certificate Authority/CN=VPN-CA" \
    || openssl req -new -x509 -days 365 -key ca-key.pem -out ca-cert.pem
echo "✓ CA certificate created: ca-cert.pem"
echo

# 3. Create server private key
echo "Step 3/8: Generating server private key..."
openssl genrsa -out server-key.pem 4096
echo "✓ Server private key created: server-key.pem"
echo

# 4. Create server certificate request
echo "Step 4/8: Creating server certificate request..."
prompt_cert_details "Server"
openssl req -new -key server-key.pem -out server-req.pem \
    -subj "/C=US/ST=State/L=City/O=VPN-Server/OU=Server/CN=localhost" \
    || openssl req -new -key server-key.pem -out server-req.pem
echo "✓ Server certificate request created: server-req.pem"
echo

# 5. Sign server certificate with CA
echo "Step 5/8: Signing server certificate with CA..."
openssl x509 -req -in server-req.pem -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem -days 365
echo "✓ Server certificate signed: server-cert.pem"
echo

# 6. Create client private key
echo "Step 6/8: Generating client private key..."
openssl genrsa -out client-key.pem 4096
echo "✓ Client private key created: client-key.pem"
echo

# 7. Create client certificate request
echo "Step 7/8: Creating client certificate request..."
prompt_cert_details "Client"
openssl req -new -key client-key.pem -out client-req.pem \
    -subj "/C=US/ST=State/L=City/O=VPN-Client/OU=Client/CN=client" \
    || openssl req -new -key client-key.pem -out client-req.pem
echo "✓ Client certificate request created: client-req.pem"
echo

# 8. Sign client certificate with CA
echo "Step 8/8: Signing client certificate with CA..."
openssl x509 -req -in client-req.pem -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out client-cert.pem -days 365
echo "✓ Client certificate signed: client-cert.pem"
echo

# Set appropriate permissions
echo "Setting secure permissions on private keys..."
chmod 600 ca-key.pem server-key.pem client-key.pem
chmod 644 ca-cert.pem server-cert.pem client-cert.pem
echo "✓ Permissions set"
echo

# Display summary
echo "=== Certificate Generation Complete ==="
echo
echo "Generated files:"
echo "  Certificate Authority:"
echo "    - ca-key.pem     (CA private key - keep secure!)"
echo "    - ca-cert.pem    (CA certificate)"
echo "  Server certificates:"
echo "    - server-key.pem (Server private key)"
echo "    - server-cert.pem (Server certificate)"
echo "  Client certificates:"
echo "    - client-key.pem (Client private key)"
echo "    - client-cert.pem (Client certificate)"
echo "  Temporary files:"
echo "    - server-req.pem (Server certificate request)"
echo "    - client-req.pem (Client certificate request)"
echo "    - ca-cert.srl    (CA serial number)"
echo
echo "All certificates are valid for 365 days."
echo "Copy the appropriate certificates to your server and client machines."
echo
echo "⚠️  SECURITY NOTE: Keep the CA private key (ca-key.pem) in a secure location!"
echo "    It can be used to create new certificates for your VPN."
echo

# Optional: Verify certificates
read -p "Would you like to verify the generated certificates? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo
    echo "=== Certificate Verification ==="
    echo
    echo "CA Certificate:"
    openssl x509 -in ca-cert.pem -text -noout | grep -E "(Subject:|Issuer:|Not Before:|Not After:)"
    echo
    echo "Server Certificate:"
    openssl x509 -in server-cert.pem -text -noout | grep -E "(Subject:|Issuer:|Not Before:|Not After:)"
    echo
    echo "Client Certificate:"
    openssl x509 -in client-cert.pem -text -noout | grep -E "(Subject:|Issuer:|Not Before:|Not After:)"
    echo
    echo "Verifying certificate chain..."
    if openssl verify -CAfile ca-cert.pem server-cert.pem; then
        echo "✓ Server certificate verification: PASSED"
    else
        echo "✗ Server certificate verification: FAILED"
    fi
    
    if openssl verify -CAfile ca-cert.pem client-cert.pem; then
        echo "✓ Client certificate verification: PASSED"
    else
        echo "✗ Client certificate verification: FAILED"
    fi
fi

echo
echo "Script completed successfully!"
echo "You can now use these certificates with your VPN server and client."