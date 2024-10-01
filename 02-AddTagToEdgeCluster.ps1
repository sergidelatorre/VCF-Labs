# Define the NSX-T Manager, credentials, and cluster name
$NsxServer = "nsx-mgmt.vcf.sddc.lab"
$NsxUsername = "admin"
$NsxPassword = "VMware123!VMware123!"
$EdgeClusterName = "EC-01"
$TagScope = "Created for"
$TagValue = "WCPReady"

# Convert credentials to a secure string
$SecPassword = ConvertTo-SecureString -String $NsxPassword -AsPlainText -Force
$NsxCredential = New-Object System.Management.Automation.PSCredential ($NsxUsername, $SecPassword)

# Connect to NSX-T Manager using the REST API
$baseUri = "https://$NsxServer/policy/api/v1"
$headers = @{
    "Content-Type" = "application/json"
    "Accept" = "application/json"
}
$credentialBase64 = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("$($NsxCredential.Username):$($NsxCredential.GetNetworkCredential().Password)"))
$headers.Add("Authorization", "Basic $credentialBase64")

# Get the Edge Cluster ID
$edgeClustersUri = "$baseUri/edge-clusters"
$edgeClusterResponse = Invoke-RestMethod -Method Get -Uri $edgeClustersUri -Headers $headers -SkipCertificateCheck
$edgeCluster = $edgeClusterResponse.results | Where-Object { $_.display_name -eq $EdgeClusterName }
$edgeClusterId = $edgeCluster.id

if ($null -eq $edgeClusterId) {
    Write-Output "Edge Cluster '$EdgeClusterName' not found."
    exit
}

# Define the new tag
$tag = [PSCustomObject]@{
    "scope" = $TagScope
    "tag"   = $TagValue
}

# Get current tags of the Edge Cluster along with revision and ETag
$edgeClusterDetailsUri = "$baseUri/edge-clusters/$edgeClusterId"
$response = Invoke-RestMethod -Method Get -Uri $edgeClusterDetailsUri -Headers $headers -SkipCertificateCheck -ResponseHeadersVariable "ResponseHeaders"
$currentTags = $response.tags


# Add the new tag to the list
$currentTags += $tag

# Update the Edge Cluster with the new tags using PUT
$updateBody = @{
    "tags"          = $currentTags
    "_revision"     = $revision
} | ConvertTo-Json -Depth 5

$updateUri = "$baseUri/edge-clusters/$edgeClusterId"
$headers.Add("If-Match", $eTag) # Add the If-Match header

# Execute the PUT request with the ETag and Revision parameters
Invoke-RestMethod -Method Put -Uri $updateUri -Headers $headers -Body $updateBody -ContentType "application/json" -SkipCertificateCheck

Write-Output "Tag successfully added to Edge Cluster '$EdgeClusterName'."
