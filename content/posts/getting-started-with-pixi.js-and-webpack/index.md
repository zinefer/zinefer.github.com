+++
date = "2019-02-26T19:00:37-07:00"
title = "Getting Started with Pixi.js and webpack"
description = "Basic configuration for a pixi and webpack project"
categories = "Software"
tags = ["Javascript", "Gaming", "Pixi.js", "webpack"]
+++

Using webpack and Pixi.js together is very simple. This post should help someone who is new to both but experienced in javascript get off the ground quickly.

## Steps
- [Setup basic file structure](#setup-basic-file-structure)
- [Install webpack](#install-webpack)
- [Configure webpack plugins](#configure-webpack-plugins)
- [Install Pixi.js](#install-pixi-js)
- [Pixi.js Basic Usage Example](#pixi-js-basic-usage-example)

## Setup basic file structure

```bash
mkdir pixijs-demo && cd pixijs-demo
npm init -y
```

## Install webpack
```bash
npm install webpack webpack-cli webpack-dev-server --save-dev
```

Add a `build` and `start` script to your `package.json`

{{< highlight json "hl_lines=8-9" >}}
{
  "name": "pixijs-demo",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "build": "webpack",
    "start": "webpack-dev-server"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "devDependencies": {
    "webpack": "^4.29.5",
    "webpack-cli": "^3.2.3",
    "webpack-dev-server": "^3.2.1"
  }
}
{{< / highlight >}}

Create `webpack-config.js`:

```javascript
const path = require('path');

module.exports = {
  entry: './src/index.js',
  plugins: [
  ],
  output: {
    filename: 'main.js',
    path: path.resolve(__dirname, 'dist')
  }
};
```

## Configure webpack plugins

- `clean-webpack-plugin` to clean the `dist` folder between builds
- `html-webpack-plugin` to generate an index.html in the `dist` folder
- `copy-webpack-plugin` to copy assets from `src` to `dist`

```bash
npm install clean-webpack-plugin html-webpack-plugin copy-webpack-plugin --save-dev
```

Configure the plugins in `webpack.config.js`

{{< highlight javascript "hl_lines=2-4 9-15" >}}
const path = require('path');
const CleanWebpackPlugin = require('clean-webpack-plugin');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const CopyPlugin = require('copy-webpack-plugin');

module.exports = {
  entry: './src/index.js',
  plugins: [
    new CleanWebpackPlugin(['dist']),
    new HtmlWebpackPlugin({
      title: 'Pixi.js Demo'
    }),
    new CopyPlugin([
      { from: 'src/assets', to: 'assets' },
    ])
  ],
  output: {
    filename: 'main.js',
    path: path.resolve(__dirname, 'dist')
  }
};
{{< / highlight >}}

## Install Pixi.js

```bash
npm install pixi.js --save
```

Now all we need to do is import and we're good to go.
```javascript
import * as PIXI from 'pixi.js';
```

## Pixi.js Basic Usage Example

Save [bunny.png](bunny.png) to `src/assets/bunny.png`.

Create `src/index.js`:
```javascript
import * as PIXI from 'pixi.js';

// The application will create a renderer using WebGL, if possible,
// with a fallback to a canvas render. It will also setup the ticker
// and the root stage PIXI.Container
const app = new PIXI.Application();

// The application will create a canvas element for you that you
// can then insert into the DOM
document.body.appendChild(app.view);

// load the texture we need
PIXI.Loader.shared.add('bunny', 'assets/bunny.png').load((loader, resources) => {
    // This creates a texture from a 'bunny.png' image
    const bunny = new PIXI.Sprite(resources.bunny.texture);

    // Setup the position of the bunny
    bunny.x = app.renderer.width / 2;
    bunny.y = app.renderer.height / 2;

    // Rotate around the center
    bunny.anchor.x = 0.5;
    bunny.anchor.y = 0.5;

    // Add the bunny to the scene we are building
    app.stage.addChild(bunny);

    // Listen for frame updates
    app.ticker.add(() => {
         // each frame we spin the bunny around a bit
        bunny.rotation += 0.01;
    });
});
```