# .NET MAUI - Apple Provisioning

GitHub Action to help provision Apple Certificates and Provisioning Profiles for .NET & .NET MAUI iOS/MacCatalyst Apps

## What the action does

The action helps by performing a few key steps to provision the action runner:

### 1. Creates a temporary keychain
When importing developer or distribution certificates into keychain, it's a good idea to create a temporary keychain for use which can later be easily deleted.  Hosted runners always use a clean image so it's less of a concern here, but it tends to cause less problems with keychain unlocking if you still use a temporary keychain, so this is what the action does for you.

It will also by default assign a password to that keychain file which you shouldn't need to know for any other operations since the action also unlocks the keychain, and sets it as default, however you can override the password if you wish to as well.

### 2. Imports Apple Certificate

Your Apple certificates including the private key portion must be imported in order to actually build your app.  This is done by importing the certificate into the keychain previously created.

Your certificate should be stored in a GitHub Secret as a base64 encoded string of the binary .p12/.pfx file with no newlines or any whitespace in the string.

Once you have exported your private and public key information from Keychain.app and have a .p12 file, you can convert it into a base64 string in Terminal with the global dotnet tool:

```
# Installs the dotnet global tool
dotnet tool install --global AppleDev.Tools

# Generates a base64 encoded string of the binary file and copies it to clipboard
apple ci secret --from-binary-file ./path/to/certificate.p12 | pbcopy
```

> NOTE: This string value is usually rather large, and should not be passed by value directly as an input, but rather by passing the name of the environment variable for which the value is stored in.

If you specified a passphrase when exporting the .p12 certificate store, you will need to specify the same value in the action's `certificate-passphrase` input parameter.

### 3. Downloads & Installs Provisioning Profiles

Using the [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi/), the action will download and install all Provisioning Profiles from your developer account (for the API key information you supply) matching the given *Bundle Identifiers* (eg: codes.redth.myawesomeapp) and/or *Profile Types* (eg: IOS_APP_ADHOC).

You can specify one or more values in the _bundle-identifiers_ parameter as well as one or more values in the _profile-types_ parameter.

In order to connect to the App Store Connect API, you will need to [Create an API Key](https://developer.apple.com/documentation/appstoreconnectapi/creating_api_keys_for_app_store_connect_api) and supply its 3 distinct values to the action:

1. **Key ID** (eg: `A1B2C3D4E5` - 10 character identifier)
2. **Issuer ID** (eg: `12abcd3e-4567-a123-fg89-0ij12lm34n56` - 36 character GUID)
3. **Key File** (.p8) Contents (eg: `-----BEGIN PRIVATE KEY-----BASE64ENCODEDSTRING==-----END PRIVATE KEY-----`)

You can pass these values in as input parameters, or you can assign their values to environment variables with the names: `APP_STORE_CONNECT_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID` and `APP_STORE_CONNECT_PRIVATE_KEY`.


## Example - Basic Usage

```
env:
  APPLE_CERTIFICATE: ${{ secrets.APPLE_CERTIFICATE }}
  APP_STORE_CONNECT_KEY_ID: ${{ secrets.APP_STORE_CONNECT_KEY_ID }}
  APP_STORE_CONNECT_ISSUER_ID: ${{ secrets.APP_STORE_CONNECT_ISSUER_ID }}
  APP_STORE_CONNECT_PRIVATE_KEY: ${{ secrets.APP_STORE_CONNECT_PRIVATE_KEY }}

steps:
- uses: maui-actions/apple-provisioning@2
  with:
    certificate: APPLE_CERTIFICATE
    certificate-passphrase: ${{ secrets.APPLE_CERTIFICATE_PASSPHRASE }}
    bundle-identifiers: 'codes.redth.myamazingapp'
    profile-types: 'IOS_APP_ADHOC,IOS_APP_STORE'
```

## Example - Advanced

```
steps:
- uses: maui-actions/apple-provisioning@2
  with:
    keychain: 'build.keychain-db'
    keychain-password: 'build1234'
    certificate: ./cert.p12
    certificate-passphrase: 'mycert1234'
    bundle-identifiers: 'codes.redth.myamazingapp,com.company.app'
    profile-types: 'IOS_APP_ADHOC,IOS_APP_STORE'
    app-store-connect-key-id: 'A1B2C3D4E5'
    app-store-connect-issuer-id: '12abcd3e-4567-a123-fg89-0ij12lm34n56'
    app-store-connect-private-key: '-----BEGIN PRIVATE KEY-----BASE64ENCODEDSTRING==-----END PRIVATE KEY-----'
```


## Input Parameters

#### **keychain** (Optional)
Keychain file to create and use for importing certificates

#### **keychain-password** (Optional)
Password for keychain (creating or just for unlocking an existing keychain)

#### **certificate** (Required)
 Certificate to import.  This can be the name of an environment variable with the Base64 value of the binary .p12 certificate file, or the filename to the certificate file itself.

#### **certificate-passphrase** (Optional)
Passphrase for the certificate store file if it was created with one.


#### **app-store-connect-key-id** (Required)
Key ID for the App Store Connect API Key.  This may be specified as an input, or can be inferred from the contents of the environment variable _APP_STORE_CONNECT_KEY_ID_

#### **app-store-connect-issuer-id**
Issuer ID for the App Store Connect API Key.  This may be specified as an input, or can be inferred from the contents of the environment variable _APP_STORE_CONNECT_ISSUER_ID_

#### **app-store-connect-private-key**
Private Key (.p8) file contents for the App Store Connect API Key.  This may be specified as an input, or can be inferred from the contents of the environment variable _APP_STORE_CONNECT_PRIVATE_KEY_

#### **install-app-store-connect-private-key** (Optional)
Flag to indicate if the App Store Connect private key should be saved to disk.  Default is `false`.

#### **app-store-connect-private-key-directory**  (Optional)
Directory to save the App Store Connect private key to.  Default is `~/private_keys`

#### **bundle-identifiers** (Required)
Comma separated list of one or more bundle identifiers to match for downloading and installing provisioning profiles.

#### **profile-types** (Optional)
Comma separated list of one or more profile types identifiers to match for downloading and installing provisioning profiles.

Possible values include:
- IOS_APP_DEVELOPMENT
- IOS_APP_STORE
- IOS_APP_ADHOC
- IOS_APP_INHOUSE,
- MAC_APP_DEVELOPMENT
- MAC_APP_STORE
- MAC_APP_DIRECT
- TVOS_APP_DEVELOPMENT
- TVOS_APP_STORE
- TVOS_APP_ADHOC
- TVOS_APP_INHOUSE
- MAC_CATALYST_APP_DEVELOPMENT
- MAC_CATALYST_APP_STORE
- MAC_CATALYST_APP_DIRECT
