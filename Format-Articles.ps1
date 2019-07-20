param(
    [parameter(Mandatory=$true)][securestring]$GitHubPAT
)

$ArticlesToPublish = Get-Content .\posts\posts.json | ConvertFrom-Json

foreach($ArticleToPublish in $ArticlesToPublish.posts) {
    $path = ".\posts\"+$ArticleToPublish.folder+"\post.md"

    Write-Output "Transforming and uploading Gists..."
    .\Format-Gists.ps1 -Path $path -GitHubPAT $GitHubPAT -PostName $ArticleToPublish.name

    Write-Output "Transforming links to images..."
    .\Format-Images.ps1 -Path $path
}