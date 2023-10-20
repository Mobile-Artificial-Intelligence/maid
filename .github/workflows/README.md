# Build Instructions

## Android

### Create keystore:

Linux / macOS
```bash
keytool -genkey -v -keystore maid-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias maid-key-alias
```

For Windows:

```cmd
"%JAVA_HOME%\bin\keytool.exe" -genkey -v -keystore my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias
```

### Storing Secrets in GitHub

1. **Upload Keystore File**: First, base64 encode your keystore file so you can add it as a GitHub secret. Run the following command in your terminal:

```bash
base64 -i path/to/keystore/file > keystore_base64.txt
```

2. **Add Secrets**: Open your GitHub repository, navigate to `Settings` > `Secrets`, and then add the following secrets:
    - `KEYSTORE`: Paste the content of `keystore_base64.txt` here.
    - `KEY_ALIAS`: Your key alias.
    - `KEY_PASSWORD`: Your key password.
    - `STORE_PASSWORD`: Your keystore password.

