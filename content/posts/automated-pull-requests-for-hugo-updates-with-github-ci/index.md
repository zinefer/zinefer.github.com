+++
date = "2020-10-16T20:46:03-06:00"
title = "Automated Pull Requests for Hugo Updates with Github-CI"
description = "A Github Actions workflow that will create a PR containing a Hugo update"
categories = "Software"
tags = ["Hugo", "Github Actions", "Automation", "Bash"]
+++

Building upon my last post about [automated regression testing for Hugo]({{< ref "/posts/visual-regression-testing-for-hugo-with-github-ci-and-backstopjs" >}}) I wanted to create a scheduled workflow that would issue pull requests for [Hugo](https://gohugo.io/) updates.

We're working with just a single file today. Let's name it `hugo-updates.yml` and put it with the rest of your [github workflow](https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-syntax-for-github-actions) files.

## Steps

- [Check the latest release](#check-the-latest-release)
- [Clone the repository](#clone-the-repository)
- [Modify the `.hugoversion`](#modify-the-hugoversion)
- [Get release notes](#get-release-notes)
- [Generate a special auth token for Github](#generate-a-special-auth-token-for-github)
- [Create the pull request](#create-the-pull-request)

<hr/><br/>

## Check the latest release

In this first step we need to check the latest release from the [github api](https://developer.github.com/v3/repos/releases/) and compare it to our `.hugoversion`. We also need to use [workflow commands](https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-commands-for-github-actions#setting-an-output-parameter) so that we can use these variables later in the workflow.

```yaml
name: Check for new Hugo versions

on:
  workflow_dispatch:
  schedule:
    - cron: 0 0 1,15 * * # Every 1st and 15th of the month

jobs:
  hugo-updates:
    runs-on: ubuntu-latest
    steps:
    - name: Check for new hugo version
      id: versions
      run: |
        # Find the latest release
        NEW=$(curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest | jq -r .name)
        
        # Download current .hugoversion file
        wget https://raw.githubusercontent.com/$GITHUB_REPOSITORY/$GITHUB_SHA/.hugoversion
        OLD=$(cat .hugoversion)

        echo "::set-output name=new::$NEW"
        echo "::set-output name=old::$OLD"
        echo "$OLD == $NEW"
```
_We `wget` the `.hugoversion` here to save a little time in the case that there is no new version instead of cloning the whole repository._ 

<br/>

## Clone the repository

This is the first step with a [conditional](https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-syntax-for-github-actions#jobsjob_idstepsif). All future steps will have this same condition and will therefore be skipped if there is not a new version.

```yaml
    - name: Clone the repository
      if: steps.versions.outputs.new != steps.versions.outputs.old
      uses: actions/checkout@v2
      with:
        ref: master
```

<br/>

## Modify the `.hugoversion`

```yaml
    - name: Modify .hugoversion
      if: steps.versions.outputs.new != steps.versions.outputs.old
      env:
        VERSION: ${{ steps.versions.outputs.new }}
      run: echo -ne $VERSION > .hugoversion
```

<br/>

## Get release notes

In this step we use the github api again to get the release notes for the new version. We need to escape some characters before setting the output to [preserve the newlines](https://github.community/t/set-output-truncates-multiline-strings/16852).

```yaml
    - name: Get hugo release notes
      id: release
      if: steps.versions.outputs.new != steps.versions.outputs.old
      env:
        VERSION: ${{ steps.versions.outputs.new }}
      run: |
        RELEASE_NOTES="$(
          curl -s https://api.github.com/repos/gohugoio/hugo/releases \
            | jq -r --arg version $VERSION \
                '.[] | select(.tag_name == $version) | .body'
        )"
        # Escape \n, \r and %
        RELEASE_NOTES="${RELEASE_NOTES//'%'/'%25'}"
        RELEASE_NOTES="${RELEASE_NOTES//$'\n'/'%0A'}"
        RELEASE_NOTES="${RELEASE_NOTES//$'\r'/'%0D'}"
        echo "::set-output name=notes::$RELEASE_NOTES"
```

<br/>

## Generate a special auth token for Github

This step isn't actually required unless you would like the pull request created to trigger other workflows (like the regression test workflow in the last post). Pull requests created with a `GITHUB_TOKEN` cannot trigger them so we use a different type of authentication that can. Here's a great guide on how to [use a GitHub App to generate a token](https://github.com/peter-evans/create-pull-request/blob/master/docs/concepts-guidelines.md#triggering-further-workflow-runs).

```yaml
    - name: Generate token for Pull Request
      id: generate-token
      uses: tibdex/github-app-token@v1
      if: steps.versions.outputs.new != steps.versions.outputs.old
      with:
        app_id: ${{ secrets.PR_APP_ID }}
        private_key: ${{ secrets.PR_APP_PRIVATE_KEY }}
```

<br/>

## Create the pull request

Finally, we create the pull request!

```yaml
    - name: Create Pull Request
      uses: peter-evans/create-pull-request@v3
      if: steps.versions.outputs.new != steps.versions.outputs.old
      with:
        token: ${{ steps.generate-token.outputs.token }}
        labels: test-for-regression
        branch: hugo-${{ steps.versions.outputs.new }}
        commit-message: Update Hugo to ${{ steps.versions.outputs.new }}
        title: Update Hugo to ${{ steps.versions.outputs.new }}
        body: |
          :crown: Hugo update!

          # ${{ steps.versions.outputs.new }} Release Notes
          ${{ steps.release.outputs.notes }}
```