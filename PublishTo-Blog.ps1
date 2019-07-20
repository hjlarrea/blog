param(
    [parameter(Mandatory=$true)][securestring]$MediumToken,
    [parameter(Mandatory=$true)][string]$MediumUserId,
    [parameter(Mandatory=$true)][ValidateSet('draft','public')][string]$PublishStatus
)

$ArticlesToPublish = Get-Content .\posts\posts.json | ConvertFrom-Json

foreach($ArticleToPublish in $ArticlesToPublish.posts) {
    $path = ".\posts\"+$ArticleToPublish.folder+"\post.md"

    Write-Output "Publishing to Medium..."
    .\Publish-Article.ps1 -Title $ArticleToPublish.name -Path $path -Tags $ArticleToPublish.tags -userId $MediumUserId -Token $MediumToken -PublishStatus $PublishStatus
}