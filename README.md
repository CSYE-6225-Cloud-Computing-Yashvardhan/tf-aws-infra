# Steps to create and import SSL Certificate

### 1. Generata private key using below command
- openssl genrsa -out private.key 2048

### 2. Generate CSR using below command
- openssl req -new -newkey rsa:2048 -nodes -keyout private.key -out csr.pem

### 3. Use the CSR generated in prev step to activate SSL certified in SSL provider portal.

### 4. Import SSL certified using AWS CLI
- aws acm import-certificate --certificate fileb://demo_yashl_me.crt --certificate-chain fileb://demo_yashl_me.ca-bundle --private-key fileb://private.key --region us-east-1
