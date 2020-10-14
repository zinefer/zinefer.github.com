const basicConfig = require("./basic");
const ONE_SECONDS_IN_MS = 1000;
const scenarios = [];
const viewports = [];

basicConfig.relativeUrls.map(relativeUrl => {
  scenarios.push({
    label: relativeUrl,
    url: `${basicConfig.baseUrl}${relativeUrl}`,
    delay: ONE_SECONDS_IN_MS,
    requireSameDimensions: false,
    hideSelectors: ['iframe'],
  });
});

basicConfig.viewports.map(viewport => {
  if (viewport === "phone") {
    pushViewport(viewport, 320, 480);
  }
  if (viewport === "tablet") {
    pushViewport(viewport, 1024, 768);
  }
  if (viewport === "desktop") {
    pushViewport(viewport, 1280, 1024);
  }
});

function pushViewport(viewport, width, height) {
  viewports.push({
    name: viewport,
    width,
    height,
  });
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