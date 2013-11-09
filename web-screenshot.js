#!/usr/bin/env phantomjs
// Requires phantomjs from http://phantomjs.org/download.html
// just extract and copy bin/phantomjs to /usr/local/bin (or other location in path)
var page = require('webpage').create(),
    system = require('system'),
    url, outfile;

if (system.args.length < 3) {
    console.log('Usage: yaptest-screenshot.js URL filename');
    phantom.exit(1);
}
page.viewportSize = { width: 1280, height: 1024};
url = system.args[1];
outfile = system.args[2];

page.open(url, function () {
    page.render(outfile);
    phantom.exit();
});
