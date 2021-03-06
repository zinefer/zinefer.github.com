+++
date = "2019-11-16T20:31:25-07:00"
title = "Getting started with goBuffalo and Vue.js"
description = "Asset pipeline, Testing, Docker, Travis-CI and CD for goBuffalo and Vuejs"
categories = "Software"
tags = ["Go", "goBuffalo", "Webpack", "Vue.js", "Jest", "Travis-ci", "Coveralls", "Docker"]
+++

This is the first part of a guide intended to assist in start a new [Vue.js](https://vuejs.org/) project ontop of [Buffalo](https://gobuffalo.io/). In this first part we will integrate Vue.js into the Buffalo asset pipeline, adjust the tests and create a base to begin development upon in the next post.

# Prerequisites

- Install Golang
- Install Buffalo
- Install Postgresql
- Install Docker
- Install Vue/cli

# Sections

- [Prerequisites](#prerequisites)
- [Integrating Vue.js into Buffalo asset pipeline](#integrating-Vue.js-into-Buffalo-asset-pipeline)
- [Create Vue app placeholder](#create-vue-app-placeholder)
- [Setup Vue.js testing with Jest](#setup-vue-js-testing-with-jest)
- [Exploring the Buffalo test tooling](#exploring-the-buffalo-test-tooling)
- [Creating and running the Docker image](#creating-and-running-the-docker-image)
- [Enable Travis-CI](#enable-travis-ci)
- [Enable Coveralls](#enable-coveralls)

<br/>

--------------------------------

# Generate application

```bash
# Generate a buffalo app
buffalo new myapp && cd myapp
# Generate pop config
buffalo pop g config
# Create databases with pop
buffalo pop create -a
```

If the pop commands fail and you have postgresql installed and running you likely have not granted the proper permissions. You will need to adjust the [`pg_hba.conf`](https://www.postgresql.org/docs/9.1/auth-pg-hba-conf.html) file to fit your scenario.

<br/>

# Integrating Vue.js into Buffalo asset pipeline

The Buffalo asset pipeline is just webpack. So we're going to simply apply a [manual setup of vue-loader](https://vue-loader.vuejs.org/guide/#manual-setup).

```bash
# sudo yarn global add @vue/cli
yarn add vue vue-loader vue-router vue-template-compiler
```

## Modify webpack.config.js

The resolve alias is for cleaner import statements in our application.js file later on.

```js {hl_lines=[2,10,20,"32-35"]}
// ...
const VueLoaderPlugin = require('vue-loader/lib/plugin');
// ...

const configurator = {
  // ...
  plugins() {
    var plugins = [
      // ...
      new VueLoaderPlugin(),
      // ...
    ];
    // ...
  },
  // ...
  moduleOptions: function() {
    return {
      rules: [
        // ...
        { test: /\.vue/, loader: "vue-loader" },
        // ...
      ]
    }
  },
  // ...
  buildConfig: function(){
    // ...
    var config = {
      // ...
      resolve: {
        // ...
        alias: {
          vue$: `${__dirname}/node_modules/vue/dist/vue.esm.js`,
          router$: `${__dirname}/node_modules/vue-router/dist/vue-router.esm.js`
        }
      }
    }
    // ...
  }
}
// ...
```

<br/>

# Create Vue app placeholder

We are going to replace the generated front-end with a Vue app that has a single index route and add routes to get there.

## Modify actions/app.go

Add a route to access the Vue app

```golang {hl_lines=[5]}
// ...
func App() *buffalo.App {
  if app == nil {
    // ...
    app.GET("/", HomeHandler)

    app.ServeFiles("/", assetsBox) // serve files from the public directory
  }
  // ...
}
// ...
```

Some tutorials recommend using `app.GET("/{path:.+}", HomeHandler)` to capture all requests and send them to the Vue app. Due to the way `ServeFiles` works (I think this was changed at some point but was unable to find the version it happened) you can't really have a catch all route off the index. One way to get around this would be to nest your application in a path like `"/app/{path:.+}"`. This is probably a fine solution but I care about my urls too much so for this guide we will create a more verbose routes list than we would normally have to with Buffalo.

## Remove generated Buffalo templates

```bash
rm templates/_flash.plush.html
rm templates/index.plush.html
```

## Modify templates/application.plush.html

Remove the flash partial call from this file.

```golang
<%= partial("flash.html") %>
```

## Create templates/index.html

```html
<div id="app">
  <router-view></router-view>
</div>
```

## Modify actions/home_test.go

At this point our tests are broken but we can fix them. `home_test.go` checks the contents of the home handler and we've altered it. Lets change `"Welcome to Buffalo"` to `"<div id=\"app\">"`.

## Create assets/js/pages/home.vue

```vue
<template>
<div>
  <h1 class="page-header">Welcome</h1>
</div>
</template>

<script charset="utf-8">
export default {
  data() {
    return { };
  },
  created() { },
  watch: { },
  methods: { }
};
</script>
```

## Modify assets/js/application.js

```js {hl_lines=["4-6","10-23"]}
require("expose-loader?$!expose-loader?jQuery!jquery");
require("bootstrap/dist/js/bootstrap.bundle.js");

import Vue from "vue";
import VueRouter from "router";
import HomePage from "./pages/home.vue";

$(() => {

  Vue.use(VueRouter);

  const routes = [
    {path: "/", component: HomePage}
  ];

  const router = new VueRouter({
    mode: "history",
    routes
  });

  const app = new Vue({
    router
  }).$mount("#app");

});
```

At this point your tests should pass with `buffalo test` and you can access your Vue app via `buffalo dev`.

<br/>

# Setup Vue.js testing with Jest

```bash
yarn add --dev jest vue-jest babel-core@bridge @vue/test-utils
```

## Modify the package.json

Configure Jest.

```js {hl_lines=[5,"8-14"]}
{
  // ...
  "scripts": {
    // ...
    "test": "jest"
  },
  // ...
  "jest": {
    "moduleFileExtensions": [ "js", "json", "vue" ],
    "transform": {
      "^.+\\.js$": "babel-jest",
      "^.+\\.vue$": "vue-jest"
    }
  }
}
```

## Create assets/js/test/unit/home.spec.js

```javascript
import { shallowMount } from '@vue/test-utils'
import HomePage from "../../pages/home.vue";

let wrapper = null

beforeEach(() => {
  wrapper = shallowMount(HomePage)
})

afterEach(() => {
  wrapper.destroy()
})

describe('Home', () => {
  it('renders Welcome', () => {
    expect(wrapper.find('.page-header').text()).toContain('Welcome')
  })
})
```

## Running Vue.js tests

```bash
yarn test
```

<br/>

# Exploring the Buffalo test tooling

## Code coverage

```bash
# Generate a coverage profile
buffalo test -covermode=count -coverprofile=c.out ./...
# You can get a really nice visualization of tested code with the cover tool
go tool cover -html=c.out
```

_If you're on WSL you can use `wslpath -w` to convert the file path to one you can use in your windows browser._

## Race condition detection

```bash
buffalo test -race ./...
```

## Run a single test

```bash
buffalo test -m "FooMethod"
```

## Test _everything_

This runs your tests and dependancy tests and is usually only done before publishing an application as it takes quite a long time.

```bash
buffalo test all
```

<br/>

# Creating and running the Docker image

Buffalo generated a docker file for us when we created our appplication. Let's build it with:

```bash
docker build . -t myapp
```

Before running our Docker image we will likely need to change our postgresql configuration to allow connections from the container. This is very dependant on where and how you are running your local postgresql for development. I am running my postgres on localhost so I was [able to follow these instructions](https://gist.github.com/MauricioMoraes/87d76577babd4e084cba70f63c04b07d).

## Running the image

```bash
docker run -it -p "3000:3000" myapp
```

You should be able to access your app from the browser via http://localhost:3000.

# Enable Travis-CI

Follow [this guide](https://docs.travis-ci.com/user/tutorial/) to give travis permissions to your repository.

## Create .travis.yml

```yaml
dist: bionic

services:
  - postgresql
addons:
  postgresql: 10

language: go
go:
- 1.12.x
# Force-enable Go modules. This will be unnecessary when Go 1.14 lands.
env: GO111MODULE=on

# Only clone the most recent commit.
git:
  depth: 1

before_script:
  # Install buffalo
  - wget https://github.com/gobuffalo/buffalo/releases/download/v0.15.1/buffalo_0.15.1_linux_amd64.tar.gz
  - tar -xvzf buffalo_0.15.1_linux_amd64.tar.gz
  - sudo mv buffalo /usr/local/bin/buffalo
  # Install goveralls to push code coverage to coverage.io
  - go get github.com/mattn/goveralls

script:
  - go vet ./...
  - buffalo test -covermode=count -coverprofile=c.out ./...
  - yarn install --no-progress
  - yarn test
  - buffalo build --static

after_script:
  - $GOPATH/bin/goveralls -coverprofile=c.out -service=travis-ci
  - cat ./coverage/lcov.info | yarn run coveralls
```

# Enable Coveralls

Give [coveralls.io](https://docs.coveralls.io/) permissions to your repository.

```bash
yarn add --dev coveralls
```

## Modify .travis.yml

```yaml {hl_lines=["5-6","10-12"]}
# ...

before_script:
  # ...
  # Install goveralls to push code coverage to coverage.io
  - go get github.com/mattn/goveralls

# ...

after_script:
  - $GOPATH/bin/goveralls -coverprofile=c.out -service=travis-ci
  - cat ./coverage/lcov.info | yarn run coveralls
```