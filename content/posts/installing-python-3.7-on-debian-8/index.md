+++
date = "2018-10-18T12:25:46-06:00"
title = "Installing Python 3.7 on Debian 8"
description = "How to install Python 3.7 on Debian Jessie"
categories = "Software"
tags = ["Python", "System Administration"]
+++

I have a Debian Jessie box that needed to get Python 3.7 running and it was not so straight forward.

Here are some of the errors I experienced during the trial and error of figuring this out:

```
ERROR: The Python ssl extension was not compiled. Missing the OpenSSL lib?
```

```
Following modules built successfully but were removed because they could not be imported:
_ssl

Could not build the ssl module!
Python requires an OpenSSL 1.0.2 or 1.1 compatible libssl with X509_VERIFY_PARAM_set1_host().
```

```
[SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: unable to get local issuer certificate
```

# Fixing things

First, some prerequisites:

```bash
sudo apt-get install build-essential checkinstall libreadline-gplv2-dev libncursesw5-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev
```

The first problem is that the packaged versions of openssl and libssl-dev are missing header information required to build Python 3.7+ so you will have to compile your own:

```bash
cd /usr/src
curl https://www.openssl.org/source/openssl-1.0.2o.tar.gz | tar xz
cd openssl-1.0.2o
./config shared --prefix=/usr/local/
sudo make
sudo make install
```

We will need to pass `/usr/src/openssl-1.0.2o` into the Python configure script. However, the configure script will look for a `lib` directory in that path which doesn't exist. So we'll create that manually:

```bash
mkdir lib
cp ./*.{so,so.1.0.0,a,pc} ./lib
```

Now proceed with installing Python:

```bash
cd /usr/src
sudo wget https://www.python.org/ftp/python/3.7.0/Python-3.7.0.tgz
sudo tar xzf Python-3.7.0.tgz
cd Python-3.7.0
./configure --with-openssl=/usr/src/openssl-1.0.2o --enable-optimizations
sudo make
sudo make altinstall
```

To test it out, run `python3.7` and input:

```py
import ssl
ssl.OPENSSL_VERSION
```

You should see a string like `'OpenSSL 1.0.2o  27 Mar 2018'` in return.

I don't know if this will apply for everyone, but I also had to install `certifi` and manually link the certificate.

```bash
pip3.7 install certifi
sudo ln -s /usr/local/lib/python3.7/site-packages/certifi/cacert.pem /usr/local/ssl/cert.pem
```
