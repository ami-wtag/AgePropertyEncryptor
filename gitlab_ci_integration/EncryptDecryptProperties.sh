#!/bin/bash

# Configuration variables
ENCRYPTED_FILE_SUFFIX=".age"
RECIPIENT_KEY="your public key from key.txt"

# Check if the base64-encoded secret key is available as a GitLab CI secret
if [[ -z "$CI_AGE_SECRET_KEY_BASE64" ]]; then
    echo "Error: GitLab CI secret variable CI_AGE_SECRET_KEY_BASE64 not set."
    exit 1
fi

# Decode the secret key from base64 to a temporary file
RANDOM_STRING=$(openssl rand -hex 6)
temp_key_file=$(mktemp "tmp/${RANDOM_STRING}/age-key-XXXXXXXX.json")
mkdir -p "$(dirname "$temp_key_file")" && chmod 700 "$(dirname "$temp_key_file")"
chmod 600 "$temp_key_file"
echo "$CI_AGE_SECRET_KEY_BASE64" | base64 -d > "$temp_key_file"

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
        age --decrypt --identity "$temp_key_file" --output "$original_file" "$file"
        if [[ $? -ne 0 ]]; then
            echo "Error: Decryption failed for $file. Please verify the key and try again."
            rm -r "$(dirname "$temp_key_file")"
            exit 1
        fi
        rm "$file"
    done

    rm -r "$(dirname "$temp_key_file")"
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
