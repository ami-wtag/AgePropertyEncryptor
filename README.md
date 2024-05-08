# AgePropertyEncryptor

**Encrypt-Decrypt Properties Script**:
This script provides a way to encrypt and decrypt `.properties` files using the Age encryption tool. It ensures secure handling of sensitive files with minimal manual intervention and integrates seamlessly into various workflows.

## Prerequisites

- **Age Tool**: The script depends on the Age tool for encryption and decryption.
- **Bash Shell**: This script is designed to work on Unix-like systems, including macOS and Linux.

## Installation Setup

1. **Install Age Tool**:
   - On **macOS**:
        1. Install using [Homebrew](https://brew.sh/):
             ```bash
             brew install age
             ```

   - On **Linux**:
     1. Download the latest release from the [Age GitHub Releases](https://github.com/FiloSottile/age/releases).
     2. Extract the downloaded `.tar.gz` archive:
         ```bash
         tar -xzf age-vX.Y.Z-linux-amd64.tar.gz
         ```
     3. Move `age` and `age-keygen` binaries to `/usr/local/bin`:
         ```bash
         sudo mv age age-keygen /usr/local/bin
         ```
   - Verify installation by checking the versions:

        ```bash
        age --version
        age-keygen --version
        ```

2. **Generate Encryption Key**:
    - Generate a new key file using `age-keygen`:
      ```bash
      age-keygen > key.txt
        ```
        
        **Important Note**: The `key.txt` file contains your private key starting with `AGE-SECRET-KEY-`. Keep this file secure and private.

3. **Retrieve the Public Key**:
    - The public key, or "recipient key," can be derived from `key.txt`.
    - It will look like `age1...` and be listed after `# public key`.
    - *Make sure to replace it, otherwise you will get error with recepient key.*

### Usage Instructions

1. **Replace `RECIPIENT_KEY`**:
   - In the provided script, replace the `RECIPIENT_KEY` variable with your public key derived from `key.txt`.
       ```bash
       RECIPIENT_KEY="age1yourderivedpublickey"
        ```
    
2. **Make Script Executable:**
    - Ensure the script file has executable permissions.
        ```bash
        chmod +x EncryptDecryptProperties.sh
        ```

3. **Encrypting Files:**
    - Run the script with the encrypt argument to encrypt all .properties files:
        ```bash
        ./EncryptDecryptProperties.sh encrypt
        ```
        All `.properties` files will be encrypted and given the `.age` extension.

4. **Decrypting Files:**
    - Run the script with the decrypt argument to decrypt all .age files:
        ```bash
        ./EncryptDecryptProperties.sh decrypt
        ```
        All decrypted files will be restored to their original `.properties` format.
