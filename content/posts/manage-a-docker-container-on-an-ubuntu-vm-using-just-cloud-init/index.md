+++
date = "2020-10-21T20:18:05-06:00"
title = "Manage a Docker container on an Ubuntu VM with Cloud-Init"
description = "A quick example of how configure an Ubuntu VM to run a Docker container using only Cloud-Init"
categories = "Software"
tags = ["System Administration", "Docker", "Cloud-Init"]
+++

There are times when you might want to host a [Docker](https://www.docker.com/) container but a [managed app service](https://azure.microsoft.com/en-us/services/app-service/) isn't sufficient and a full blown [Kubernetes](https://kubernetes.io/) cluster would be overkill.

For a situation like this, hosting the container on a standard [Virtual Machine](https://en.wikipedia.org/wiki/Virtual_machine) could be just the solution. It's extremely easy and lightweight solution to bootstrapping the virtual machine with [Cloud-Init](https://cloud-init.io/) which might normally be done with a tool like [Ansible](https://www.ansible.com/) or [Chef](https://www.chef.io/).

<hr/>
<br/>

Accomplishing this is 3 basic steps:

- Install Docker
- Create a [systemd](https://www.digitalocean.com/community/tutorials/understanding-systemd-units-and-unit-files) service file
- Start and Enable the container service

### 
```yaml
#cloud-config

apt:
  sources:
    docker.list:
      source: deb [arch=amd64] https://download.docker.com/linux/ubuntu $RELEASE stable
      keyid: 9DC858229FC7DD38854AE2D88D81803C0EBFCD88

packages:
  - docker-ce
  - docker-ce-cli

write_files:
  - path: /etc/systemd/system/container.service
    owner: root:root
    permissions: '0755'
    content: |
        [Unit]
        Description=Run container
        Requires=docker.service
        After=docker.service

        [Service]
        Restart=always
        ExecStartPre=-/usr/bin/docker rm container
        ExecStart=/usr/bin/docker run --rm --name container hello-world
        ExecStop=/usr/bin/docker stop -t 2 container

runcmd:
  - systemctl start container
  - systemctl enable container
```