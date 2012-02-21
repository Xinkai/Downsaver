"use strict"

fs = require('fs')
{exec} = require('child_process')

removeFile = (path) ->
    try
        fs.unlinkSync(path)

task('clean', 'remove built files', (options) ->
    removeFile('./downsaver.xpi')

    removeFile('./lib/mozilla.js')
    removeFile('./lib/media-rules.js')

    removeFile('./test/test-mozilla.js')
    removeFile('./test/test-media-rules.js')
    removeFile('./test/test-testenv.js')
)

task('mozilla', 'build xpi for Mozilla', (options) ->
    invoke('clean')
    exec('coffee --compile --bare --output lib/ src/')
)

task('mozilla:test', 'unit test for Mozilla', (options) ->
    invoke('mozilla')
    exec('coffee --compile --bare --output test/ src_test/')
)

task('mozilla:testenv', 'unit-test with a clean-profiled Firefox open', (options) ->
    invoke('mozilla')
    exec('coffee --bare --output test/ src_test/test-testenv.coffee')
)
task('chromium', 'build crx for Chromium-based', (options) ->
    console.error('Building failed: Chromium is not supported for now.')
)