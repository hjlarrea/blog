[cmdletbinding()]
param(
    [parameter(Mandatory=$true)][string]$Title,
    [parameter(Mandatory=$true)][string]$Path,
    [parameter(Mandatory=$true)][string[]]$Tags,
    [parameter(Mandatory=$true)][string]$PublicationID ,
    [parameter(Mandatory=$true)][securestring]$Token,
    [parameter(Mandatory=$true)][ValidateSet('draft','public')][string]$PublishStatus
)

$tempCredential=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "medium",$token

$headers = @{
    "Authorization" = $("Bearer {0}" -f $tempCredential.GetNetworkCredential().Password)
}

$post = (get-content $Path -Raw).ToString()

$uri = "https://api.medium.com/v1/publications/{0}/posts" -f $PublicationID

$body = @{
    "title" = $Title
    "contentFormat" = "markdown"
    "content" = $post
    "tags" = $tags
    "publishStatus" = $PublishStatus
}

Invoke-RestMethod -Method Post -Uri $uri -Body $($body | convertto-json) -Headers $headers -ContentType "application/json" -ErrorAction Stop