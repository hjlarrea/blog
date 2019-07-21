# Introduction

Visit the blog at https://www.hernanjlarrea.com. This is the repository used for authoring the content and publishing the content using CI/CD practices.

# Repository details

## Branches
- **Master**: Used for writing and commiting.
- **Publish**: When code is merged to publish and pushed against GitHub, the CI/CD process is executed.

## Files

### fileTypes.json

A dictionary which holds the list of known snippet types.

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