[cmdletbinding()]
param(
    [parameter(Mandatory=$true)][string]$Path,
    [parameter(Mandatory=$true)][securestring]$GitHubPAT,
    [parameter(Mandatory=$true)][string]$PostName
)

function Get-FirstCodeSnippetBoundaries {
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$true)][string]$Path
    )

    $post = Get-Content -Path $Path
    $boundary = New-Object -TypeName PSCustomObject

    0..(($post.Length)-1) | ForEach-Object {
        if($post[$_] -like '``````*') {
            if(!($boundary.PSObject.Properties.Name -contains "BoundaryA")) {
                $boundary | Add-Member -MemberType NoteProperty -Name BoundaryA -Value $_
            } elseif(!($boundary.PSObject.Properties.Name -contains "BoundaryB")) {
                $boundary | Add-Member -MemberType NoteProperty -Name BoundaryB -Value $_
            }
        }
    }

    if (($boundary.PSObject.Properties.Name -contains "BoundaryA") -and ($boundary.PSObject.Properties.Name -contains "BoundaryB")) {
        $boundary
    } else {
        $null
    }
}

function Get-CodeSnippet {
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true)][string]$Path,
        [parameter(Mandatory=$true)][PSObject]$Boundaries
    )

    $post = Get-Content -Path $Path

    $snippet = $post[($Boundaries.BoundaryA+1)..($Boundaries.BoundaryB-1)] -join "`r`n"

    $snippet
}

function Get-CodeSnippetType {
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true)][string]$Path,
        [parameter(Mandatory=$true)][PSObject]$Boundaries,
        [parameter(Mandatory=$true)][string]$TypeDictionary
    )

    $knownTypes = Get-Content -Path $TypeDictionary | ConvertFrom-Json
    $post = Get-Content -Path $Path

    $type=($post[$Boundaries.BoundaryA] -split "``````")[1]
    $snippetType = $knownTypes.$type

    $snippetType
}

function Publish-Gist {
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true)][string]$PostName,
        [parameter(Mandatory=$true)][string]$PostFolderName,
        [parameter(Mandatory=$true)][string]$Snippet,
        [parameter(Mandatory=$true)][int]$SnippetNumber,
        [parameter(Mandatory=$true)][string]$SnippetType,
        [parameter(Mandatory=$true)][securestring]$GitHubPAT
    )

    $tempCredential=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "github",$GitHubPAT

    $headers = @{
        "Authorization" = $("Bearer {0}" -f $tempCredential.GetNetworkCredential().Password)
    }

    $body=@{
        "public" = $true
        "description" = $("Gist {0} for {1} post." -f $SnippetNumber,$PostName)
        "files" = @{
            $("{0}_file{1}.{2}" -f $PostFolderName,$SnippetNumber,$SnippetType) = @{
                "content" = $Snippet
            }
        }
    }

    Invoke-RestMethod -Method Post -Uri "https://api.github.com/gists" -Header $headers -Body $($Body | ConvertTo-Json)
}

function Set-CodeSnippet {
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true)][string]$Path,
        [parameter(Mandatory=$true)][string]$GistUri,
        [parameter(Mandatory=$true)][PSObject]$Boundaries
    )

    $post = Get-Content -Path $Path
    $newContent = ($post -join "`r`n").replace($post[($Boundaries.BoundaryA)..($Boundaries.BoundaryB)] -join "`r`n",$("<script src=`"{0}.js`"></script>" -f $GistUri ))
    Set-Content -Value $newContent -Path $Path
}

$PostFolderName = Split-Path $Path -Parent | Split-Path -Leaf
$boundaries = Get-FirstCodeSnippetBoundaries -Path $Path -ErrorAction Stop
$snippetCount = 0

while ($boundaries) {
    $snippetCount++
    $snippet = Get-CodeSnippet -Path $Path -Boundaries $boundaries -ErrorAction Stop
    $snippetType = Get-CodeSnippetType -Path $Path -Boundaries $boundaries -TypeDictionary .\fileTypes.json -ErrorAction Stop
    $gitHubResponse = Publish-Gist -PostName $PostName -PostFolderName $PostFolderName -Snippet $snippet -SnippetType $snippetType -SnippetNumber $snippetCount -GitHubPAT $GitHubPAT -ErrorAction Stop
    Set-CodeSnippet -Path $Path -GistUri $gitHubResponse.html_url -Boundaries $boundaries -ErrorAction Stop
    $boundaries = Get-FirstCodeSnippetBoundaries -Path $Path -ErrorAction Stop
}