+++
date = "2020-10-14T19:45:46-06:00"
title = "Visual Regression Testing for Hugo with Github-CI and BackstopJS"
description = "A guide to automated regression testing for static sites with Github Actions and BackstopJS"
categories = "Software"
tags = ["Github Actions", "BackstopJS", "Docker", "Automation", "Hugo", "Bash"]
+++

Visual Regression testing is usually accomplished by building two different versions of a website, taking screenshots of all of it's pages and then comparing them for visual differences. This is a fairly old topic with [projects](https://github.com/mojoaxel/awesome-regression-testing) going back nearly a decade. While many are deprecated or archived it's probably never been easier to automate screenshots from a browser thanks to first class automation support from Chrome.

After setting out to finally automate this and doing some research it seems there are some fairly mature and popular SaaS solutions that I could have used like [percy](http://percy.io) which appears to have a free tier and even uses [Hugo](https://gohugo.io/) as an [example](https://docs.percy.io/docs/snapshot-cli-command) in some of their docs. However, I wanted to accomplish this myself with [Github Actions](https://docs.github.com/en/free-pro-team@latest/actions/quickstart) so I continued digging until I came across [BackstopJS](https://github.com/garris/BackstopJS).

Using this tooling, the following procedure should suffice:
- Checkout master branch
- Install Hugo at version in `.hugoversion`
- Build website
- Capture reference screenshots
- Checkout branch to be tested
- Install Hugo at version in `.hugoversion`
- Build website
- Capture test screenshots
- Compare reference and test screenshots
- Upload test results as artifact

If this type of automation interests you then this post should be able to provide some insight into how to accomplish it.

## Steps

- [Setup BackstopJS scenarios](#setup-backstopjs-scenarios)
- [Create bash script helpers](#create-bash-script-helpers)
- [Create Github Actions workflow](#create-github-actions-workflow)

<hr/><br/>

## Setup BackstopJS scenarios

Let's start by creating our BackstopJs configuration. We will follow a basic pattern established by [wlsf82](https://github.com/wlsf82/backstop-config). However, I have altered it to support this approach. Choose a folder to put your files. I chose `devops/backstopjs`.

<br/>

Create `basic.js` with the contents:
```js
const baseUrl = "http://host.docker.internal:1313";
const projectId = "static-hugo";

const url = require('url');
const urls = require('./urls.json'); // Contains an array of url strings
const relativeUrls = urls.map(absUrl => {
  return url.parse(absUrl, false, true).pathname;
});

const viewports = [
  "phone",
  "tablet",
  "desktop",
];

module.exports = {
  baseUrl,
  projectId,
  relativeUrls,
  viewports,
};
```

_This file contains basic configuration and is responsible for loading and parsing your urls into a list. The `baseUrl` value of `host.docker.internal` and file `urls.json` will be explained more later in the post._

<br/>

Create `main.js` with the contents:
```js
const basicConfig = require("./basic");
const ONE_SECONDS_IN_MS = 1000;
const scenarios = [];
const viewports = [];

// Creates the list of scenarios (urls to screenshot)
basicConfig.relativeUrls.map(relativeUrl => {
  scenarios.push({
    label: relativeUrl,
    url: `${basicConfig.baseUrl}${relativeUrl}`,
    delay: ONE_SECONDS_IN_MS,
    requireSameDimensions: false,
    // hideSelectors: ['iframe'],
    // Could be used to hide (and therefore ignore) youtube videos
  });
});

basicConfig.viewports.map(viewport => {
  switch(viewport){
    case "phone":
        pushViewport(viewport, 320, 480);
      break;
    case "tablet":
        pushViewport(viewport, 1024, 768);
      break;
    case "desktop":
        pushViewport(viewport, 1280, 1024);
      break;
  }
});

function pushViewport(viewport, width, height) {
  viewports.push({ name: viewport, width, height });
}

module.exports = {
  id: basicConfig.projectId,
  viewports,
  scenarios,
  paths: {
    bitmaps_reference: 'backstop_data/bitmaps_reference',
    bitmaps_test: 'backstop_data/bitmaps_test'
  },
  report: ["browser", "CI"],
  engine: "puppeteer",
  engineOptions: {
    args: ["--no-sandbox"]
  },
  asyncCaptureLimit: 5,
  asyncCompareLimit: 50,
};
```

_This script is used to convert your basic settings into an appropriate [scenario](https://github.com/garris/BackstopJS#using-backstopjs) configuration for backstop._

<hr/><br/>

## Create bash script helpers

These bash scripts will facilitate the creation of a [workflow](https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-syntax-for-github-actions) shortly. You'll need a place to put them inside your repository. I usually go with `devops/scripts`. 

The [Taskfile](https://github.com/adriancooney/Taskfile) pattern is great for organizing your scripts conveniently for use by a developer like a Makefile.

<br/>

### Hugo installer helper

We're going to be building the website with two different hugo versions so having a script that can install a specific version of hugo for us would be very helpful. Leaning on my past post about a [hugo install command]({{< ref "/posts/install-latest-hugo-on-ubuntu-debian" >}}), here's what I came up with:

Create `install-hugo.sh`
```sh
#!/bin/bash

set -e

VFILE=".hugoversion"
VERSION=$(cat $VFILE)

echo "Searching for Hugo $VERSION"

URL=`curl -s https://api.github.com/repos/gohugoio/hugo/releases \
      | jq -r --arg version $VERSION \
          '.[] 
          | select(.tag_name == $version) 
          | .assets[] 
          | select(.browser_download_url 
          | test("hugo_extended(.*)Linux-64bit.deb")) 
          | .browser_download_url'`

echo "Found $URL"

INSTALLER=$(basename $URL)

wget -q --show-progress -P /tmp $URL

sudo dpkg -i /tmp/$INSTALLER

rm /tmp/$INSTALLER
```
_This file reads in `.hugoversion`, downloads the specified Hugo and installs it._

<br/>

### Wait for helper

We need to spawn the hugo process in the background so that we can run the testing commands. Because of this, we need to be able wait for hugo to be ready to respond.

Create `wait-for.sh`:
```sh
#!/bin/bash
URL=${1?}
CODE=${2:-200}

start=$SECONDS

timeout --foreground 300 bash \
<<-EOD
  until [[ "\$RESP" == "$CODE" ]]; do 
    [[ \$RESP ]] && sleep 1
    RESP=\$(curl -sIL -o /dev/null -w '%{http_code}' $URL | tr -d '\n')
    echo -ne "\$RESP "
    TRIES=\$(( TRIES + 1 )) && [[ \$(( TRIES % 10 )) == 0 ]] && echo
  done
EOD

duration=$(( SECONDS - start ))
RET=$?

echo 

if [[ $RET -eq 0 ]]; then
    echo "$URL returned $CODE in $duration seconds"
else
    echo "$URL timed out after $duration waiting for $CODE"
    exit 1
fi
```
_This polls `$URL` with `curl` until `$CODE` is returned with some fancy output to help debug workflows_

<br/>

### Regression test runner helper

We need to run the same basic steps twice (install, build, screenshot) so let's DRY that up with a helper script. We also need to ensure that hugo will respond to backstop in the docker container.

Create `regression.sh`:
```sh
#!/bin/bash
ACTION=${1?} # "reference" or "test"

# Start a hugo server in the background. The -b[aseUrl] is very important
hugo serve -b host.docker.internal --bind 0.0.0.0 &
# Wait for hugo to respond before continuing
./devops/scripts/wait-for.sh localhost:1313

# Download and parse the sitemap into an array of urls
curl -s http://localhost:1313/sitemap.xml \
    | npx sitemap --parse \
    | jq --slurp '. | map(.url) | sort' > devops/backstopjs/urls.json

# ADD_HOST_FLAG allows the container to make requests out to the hugo serve that is running outside of docker 
HOST_IP="$(ip route | grep -E '(default|docker0)' | grep -Eo '([0-9]+\.){3}[0-9]+' | tail -1)"
ADD_HOST_FLAG="--add-host host.docker.internal:$HOST_IP"
echo $ADD_HOST_FLAG

docker run --rm -v $(pwd):/src $ADD_HOST_FLAG \
    backstopjs/backstopjs $ACTION --config=devops/backstopjs/main.js

RET=$?
kill %1   # Stop hugo serve
exit $RET # Preserve the error code from the docker run
```

<hr/><br/>

## Create Github Actions workflow

Now it's time to tie it all together!

Create a `.github/workflows/regression-test.yml`:
```yaml
name: Check for regressions

on:
  workflow_dispatch:
  pull_request:
    branches: [ master ]

jobs:
  regression-test:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout repo at master
      uses: actions/checkout@v2
      with:
        ref: master
    
    - name: Install dependencies
      run: ./devops/scripts/install-hugo.sh

    - name: Generate Screenshots for reference
      run: ./devops/scripts/regression.sh reference

    - name: Checkout repo at ${{ github.base_ref }}
      uses: actions/checkout@v2
      with:
        clean: false # Without this the test results would be cleared

    - name: Install dependencies
      run: ./devops/scripts/install-hugo.sh

    - name: Run regression test
      run: ./devops/scripts/regression.sh test

    - name: Upload regression test results as an artifact
      if: always() # If the test fails we will often still have a report
      uses: actions/upload-artifact@v2
      with:
        name: regression-test-results
        path: backstop_data
```

<br/>

A couple of advanced things to try with this workflow:
- Only run the pipeline when the pullrequest has a particular label
- Run a docker pull for `backstop/backstopjs` in the background and `wait` for it to finish before reference
- Store your compiled resources in a separate branch to speed up builds