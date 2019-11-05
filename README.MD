![Build Status](https://hjlarrea.visualstudio.com/Blog/_apis/build/status/Blog-CI?branchName=publish)

# Introduction

Visit the blog at https://www.hernanjlarrea.com. This is the repository used for authoring the content and publishing the content using CI/CD practices.

# Authoring instructions

1. Posts are written in markdown.
1. Every post should be contained in it's own (unique) folder under the `posts` directory.
1. Every post should get it's own entry in the `posts/posts.json` file.

# Repository details

## Branches

- **Master**: Used for writing and commiting.
- **Publish**: When code is merged to publish and pushed against GitHub, the CI/CD process is executed.

## Files

- **blog.tests.ps1**: Pester tests to ensure posts are valid and compliant with the writing guidelines.
- **Build-Artifact.ps1**: Script used to copy the necessary files on the CI pipeline.
- **fileTypes.json**: See below.
- **Format-Articles**: Script that scrubs the posts to be published and formats them using the following two scripts.
- **Format-Gists**: Script that finds all the snippets in the post to be published and uploads them as Gists.
- **Format-Images**: Script that finds all the images in the post to be published and changes the references to the Github raw reference on the master branch of the repo.
- **Publish-ArticleToMedium**: Publishes one article to the Medium platform.
- **PublishTo-Medium**: Iterates over the posts to be published and executes the `Publish-ArticleToMedium` script.
- **posts/posts.json**: See below.

### fileTypes.json

A dictionary which holds the list of known code snippet types and the corresponding file extension.

```json
{
    "powershell": "ps1",
    "json": "json"
}
```

### posts/posts.json file

The file which contains the metadata of the articles stored on this repository.

```json
{
    "posts": [
        {
            "name": "Title of the article",
            "dateAuthored": "yyyy.mm.dd",
            "action": "doNotPublish | publish | published",
            "folder": "folderName",
            "tags": [
                "tag1",
                "tag2",
                "tag3"
            ]
        }
    ]
}
```