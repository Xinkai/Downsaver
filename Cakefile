"use strict"

fs = require('fs')
{exec} = require('child_process')

removeFile = (path) ->
    try
        fs.unlinkSync(path)

task('clean', 'remove built files', (options) ->
    removeFile('./downsaver.xpi')
    removeFile('./lib/main.js')
)

task('mozilla', 'build xpi for Mozilla', (options) ->
    invoke('clean')
    exec('coffee --compile --bare --output lib/ src/mozilla/')
)

task('chromium', 'build crx for Chromium-based', (options) ->
    console.error('Building failed: Chromium is not supported for now.')
)