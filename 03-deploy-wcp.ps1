# SDDC Manager FQDN
$sddcManagerFQDN = "sddc-manager.vcf.sddc.lab"

# SDDC Manager User
$sddcManagerUser = "administrator@vsphere.local"

# SDDC Manager Password
$sddcManagerPassword = "VMware123!"


# Create the JSON payload
$body = @{
    username = $sddcManagerUser
    password = $sddcManagerPassword
} | ConvertTo-Json



# Make the API call to retrieve the bearer token
$baseUri = "https://$sddcManagerFQDN/"
$response = Invoke-RestMethod -Uri $baseUri/v1/tokens `
                              -Method Post `
                              -Headers @{
                                  'Content-Type' = 'application/json'
                                  'Accept'       = 'application/json'
                              } `
                              -Body $body

# Store the tokens
$bearerToken = $response.accessToken
$refreshToken = $response.refreshToken

# Display the token (for verification)
Write-Output "Bearer Token: $bearerToken"


#Retrieve WLD List
# Define the headers with the Bearer token
$headers = @{
    "Authorization" = "Bearer $bearerToken"
    'Content-Type'  = 'application/json'
    'Accept'        = 'application/json'
}
$response = Invoke-RestMethod -Uri $baseUri/v1/domains `
                                 -Method Get `
                                 -Headers $headers

# Get the ID of the first domain
$firstDomainId = $response.elements[0].id

# Output the ID of the first domain
Write-Output "The ID of the first domain is: $firstDomainId"

