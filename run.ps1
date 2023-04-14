<#
  Runs the apple global dotnet tool (AppleDev.Tools)
#>
param(
	[Parameter(Mandatory=$False)]
	[string] $keychain,

	[Parameter(Mandatory=$False)]
	[securestring] $keychainPassword,

	[Parameter(Mandatory=$False)]
	[string] $certificate,

	[Parameter(Mandatory=$False)]
	[securestring] $certificatePassphrase,

	[Parameter(Mandatory=$False)]
	[string] $appStoreConnectKeyId,

	[Parameter(Mandatory=$False)]
	[string] $appStoreConnectIssuerId,

	[Parameter(Mandatory=$False)]
	[string] $appStoreConnectPrivateKey,

	[Parameter(Mandatory=$False)]
	[string[]] $profileTypes=@(),

	[Parameter(Mandatory=$False)]
	[string[]] $bundleIdentifiers=@()
)
$PSBoundParameters

$toolArgs = @('ci','provision')

if ($keychain) {
	$toolArgs += '--keychain'
	$toolArgs += "'$keychain'"
}

if ($keychainPassword) {
	$toolArgs += '--keychain-password'
	$toolArgs += "'$keychainPassword'"
}

if ($certificate) {
	$toolArgs += '--certificate'
	$toolArgs += "'$certificate'"
}

if ($certificatePassphrase) {
	$toolArgs += '--certificate-passphrase'
	$toolArgs += "'$certificatePassphrase'"
}

if ($appStoreConnectKeyId) {
	$toolArgs += '--app-store-connect-key-id'
	$toolArgs += "'$appStoreConnectKeyId'"
}

if ($appStoreConnectIssuerId) {
	$toolArgs += '--app-store-connect-issuer-id'
	$toolArgs += "'$appStoreConnectIssuerId'"
}

if ($appStoreConnectPrivateKey) {
	$toolArgs += '--app-store-connect-private-key'
	$toolArgs += "'$appStoreConnectPrivateKey'"
}

foreach ($profileType in $profileTypes) {
	$toolArgs += '--profile-type'
	$toolArgs += "'$profileType'"
}

foreach ($bundleIdentifier in $bundleIdentifiers) {
	$toolArgs += '--bundle-identifier'
	$toolArgs += "'$bundleIdentifier'"
}

$toolArgsStr = $toolArgs -Join ' '

& dotnet apple $toolArgsStr