#!/bin/bash

set -e

cd /tmp

wget https://aka.ms/downloadazcopy-v10-linux

tar -xvf downloadazcopy-v10-linux

sudo cp ./azcopy_linux_amd64_*/azcopy /usr/bin/

rm -rf ./azcopy_linux_amd64_*
