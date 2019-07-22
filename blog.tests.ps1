param (
    [string]$ArticleFolderName
)

if($PSBoundParameters.Keys.Contains("ArticleName")) {
    $posts = (Get-Content -Path .\posts\posts.json | ConvertFrom-Json | Where-Object {$_.folder -eq $ArticleFolderName}).posts
} else {
    $posts = (Get-Content -Path .\posts\posts.json | ConvertFrom-Json).posts
}

foreach ($post in $posts) {

    $postContent = Get-Content -Path ".\posts\$($post.folder)\post.md"

    describe "Analyzing `"$($post.name)`"" {
            
        Context -Name "Testing post assets" {

            It "Post reference in posts.json should be properly formed." {
                $post.psobject.Properties.name | Should -Contain "name"
                $post.psobject.Properties.name | Should -Contain "dateAuthored"
                $post.psobject.Properties.name | Should -Contain "action"
                $post.psobject.Properties.name | Should -Contain "folder"
                $post.psobject.Properties.name | Should -Contain "tags"
            }

            It "Post reference in posts.json should contain 3 tags." {
                $post.tags.Count | Should be 3
            }

            It "Post folder should exist." {
                ".\posts\{0}" -f $post.folder | Should -Exist
            }

            It "Post should have a post.md document." {
                ".\posts\{0}\post.md" -f $post.folder | Should -Exist
            }

            It "All images in post.md should be located under the img directory." {
                0..($postContent.Length) | ForEach-Object {
                    if($postContent[$_] -match "^!\[") {
                        $imageFileName = $postContent[$_].split("/")[-1].split(")")[0]
                        ".\posts\{0}\img\{1}" -f $post.folder,$imageFileName | Should -Exist
                    }
                }
            }

            It "All image references in post.md should be named 'image<nameOfTheFile>'." {
                0..($postContent.Length) | ForEach-Object {
                    if($postContent[$_] -match "^!\[") {
                        $imageFile = $postContent[$_].split("/")[-1].split(")")[0]
                        $imageName = $imageFile.split(".")[0]
                        $postContent[$_] | Should be "![image$($imageName)](./img/$imageFile)"
                    }
                }
            }

            It "All images in the img directory should be used in post.md." {
                $imageFiles = (Get-ChildItem -Path $(".\posts\{0}\img" -f $post.folder)).Name
                foreach ($imageFile in $imageFiles) {
                    $imageName = $imageFile.split(".")[0]
                    $postContent | Should -Contain "![image$($imageName)](./img/$imageFile)"
                }
            }
        }

        Context -Name "Testing code snippets" {
            $boundaries = New-Object -TypeName System.Collections.ArrayList

            0..($postContent.Length) | ForEach-Object {
                if($postContent[$_] -like '``````*') {
                    $boundaries.Add($_) | Out-Null
                }
            }

            It "All code snippets shold be properly opened and closed" {
               $boundaries.count%2 | Should be 0
            }

            It "Opening statement for code snippets should also have the language specified." {
                for($i = 0; $i -lt $boundaries.Count; $i = $i+2) {
                    ($postContent[$boundaries[$i]]).Length | Should -BeGreaterThan 3
                }
            }

            It "Specified languages should be included in the File Types dictionary." {
                for($i = 0; $i -lt $boundaries.Count; $i = $i+2) {
                    $types = Get-Content -Path .\fileTypes.json | ConvertFrom-Json
                    $type=($postContent[$boundaries[$i]] -split "``````")[1]
                    $types.psobject.properties.name | Should -Contain $type
                }
            }
        }
    }
}