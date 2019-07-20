param(
    [parameter(Mandatory=$true)][securestring]$GitHubPAT,
    [parameter(Mandatory=$true)][securestring]$MediumToken,
    [parameter(Mandatory=$true)][string]$MediumUserId
)

$ArticlesToPublish = Get-Content .\posts\posts.json | ConvertFrom-Json

foreach($ArticleToPublish in $ArticlesToPublish.posts) {
    $path = ".\posts\"+$ArticleToPublish.folder+"\post.md"

    .\Format-Gists.ps1 -Path $path -GitHubPAT $GitHubPAT -PostName $ArticleToPublish.name
    .\Format-Images.ps1 -Path $path
    .\Publish-Article.ps1 -Title $ArticleToPublish.name -Path $path -Tags $ArticleToPublish.tags -userId $MediumUserId -Token $MediumToken -PublishStatus $ArticleToPublish.status 
}