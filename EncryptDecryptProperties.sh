#!/bin/bash

# Configuration variables
KEY_FILE="key.txt"
ENCRYPTED_FILE_SUFFIX=".age"
RECIPIENT_KEY="age1qwcl7lyy03kvftxd5rlayr7zw6077f0p0uckzft4ansjaduuf5kqsalyfd"

# Check for key file
if [[ ! -f "$KEY_FILE" ]]; then
    echo "Error: Key file $KEY_FILE not found."
    exit 1
fi

# Usage information
function usage() {
    echo "Usage: $(basename "$0") [encrypt|decrypt]"
    exit 1
}

# Encrypt all .properties files
function encrypt_files() {
    find . -name "*.properties" -print0 | while IFS= read -r -d '' file; do
        encrypted_file="${file}${ENCRYPTED_FILE_SUFFIX}"
        echo "Encrypting $file to $encrypted_file..."
        age --output "$encrypted_file" -r "$RECIPIENT_KEY" --armor "$file"
        if [[ $? -ne 0 ]]; then
            echo "Error: Encryption failed for $file"
            exit 1
        fi
        rm "$file"
    done
    echo "Encryption completed successfully."
}

# Decrypt all .age files
function decrypt_files() {
    find . -name "*${ENCRYPTED_FILE_SUFFIX}" -print0 | while IFS= read -r -d '' file; do
        original_file="${file%${ENCRYPTED_FILE_SUFFIX}}"
        echo "Decrypting $file to $original_file..."
        age --decrypt --identity "$KEY_FILE" --output "$original_file" "$file"
        if [[ $? -ne 0 ]]; then
            echo "Error: Decryption failed for $file. Please verify the key and try again."
            exit 1
        fi
    done
    echo "Decryption completed successfully."
}

# Verify command-line argument
if [[ $# -ne 1 ]]; then
    usage
fi

# Execute the appropriate function
case "$1" in
    encrypt)
        encrypt_files
        ;;
    decrypt)
        decrypt_files
        ;;
    *)
        usage
        ;;
esac
