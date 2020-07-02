#!/bin/bash

set -e

VFILE=".hugoversion"
VERSION=$(cat .hugoversion | jq -r .)

echo "Searching for Hugo $VERSION"

URL=`curl -s https://api.github.com/repos/gohugoio/hugo/releases \
      | jq -r --argfile version .hugoversion \
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