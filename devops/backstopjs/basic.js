const url = require('url');

const baseUrl = "http://host.docker.internal:1313";
const projectId = "portfolio";

const urls = require('./urls.json');
const relativeUrls = urls.map(absUrl => {
  return url.parse(absUrl, false, true).pathname;
});

const viewports = [
  //"phone",
  //"tablet",
  "desktop",
];

module.exports = {
  baseUrl,
  projectId,
  relativeUrls,
  viewports,
};