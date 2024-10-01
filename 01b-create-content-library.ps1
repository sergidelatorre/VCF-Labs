# Connect to the vCenter Server
$vcenterFqdn = "vcenter-mgmt.vcf2.SDDC.lab"
$vcenterUsername = "administrator@vsphere.local"
$vcenterPassword = "VMware123!"
$vcenter = Connect-VIServer -Server $vcenterFqdn -User $vcenterUsername -Password $vcenterPassword

# Set the name and description of the Content Library
$libraryName = "WCP-Content-Library"
$libraryDescription = "Content Library for WCP"
$sslThumbprint = "38:7f:f1:04:ff:29:96:b8:f5:2a:7c:b8:7e:19:c9:64:59:3d:94:26"

# Set the URL of the CDN lib.json file
$cdnUrl = "https://wp-content.vmware.com/v2/latest/lib.json"

# Set the datastore where the Content Library will be created
$datastoreName = "vcf-vsan"

# Get the datastore object
$datastore = Get-Datastore -Name $datastoreName

# Create a new Content Library
New-ContentLibrary -Name $libraryName -Description $libraryDescription -Datastore $datastore -SubscriptionUrl $cdnUrl -SslThumbprint $sslThumbprint

# Disconnect from the vCenter Server
Disconnect-VIServer -Server $vcenterFqdn -Confirm:$false
