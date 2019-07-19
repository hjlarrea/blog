# Introduction

## Branches
- **Master**: Used for writing and commiting.
- **Publish**: When code is merged to publish and pushed against GitHub, the CI/CD process is executed.

## Files

### posts/posts.json file

The file which contains the metadata of the articles stored on this repository.

```json
{
    "posts": [
        {
            "name": "Title of the article",
            "status": "doNotPublish|draft|publish|published",
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