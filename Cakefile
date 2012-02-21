"use strict"

fs = require('fs')
__exec = require('child_process').exec

removeFile = (path) ->
    try
        fs.unlinkSync(path)

exec = (commandLine, onSuccess = null) ->
    __exec(commandLine, (error, stdout, stderr) ->
        console.log('stdout: ', stdout)
        console.log('stderr: ', stderr)
        if error isnt null
            console.error('exec error: ', error)
        else
            if onSuccess isnt null
                onSuccess()
    )


task('clean', 'remove built files', (options) ->
    removeFile('./downsaver.xpi')

    removeFile('./lib/mozilla.js')
    removeFile('./lib/media-rules.js')

    removeFile('./test/test-mozilla.js')
    removeFile('./test/test-media-rules.js')

    removeFile('./data/panel.js')
)

task('mozilla', 'build xpi for Mozilla', (options) ->
    invoke('clean')
    exec('coffee --compile --bare --output lib/ src/')
    exec('coffee --compile --bare --output data/ src_data/')
)

task('mozilla:test', 'unit test for Mozilla', (options) ->
    invoke('mozilla')
    exec('coffee --compile --bare --output test/ src_test/', () ->
        exec('cfx test -g testenv')
    )
)

task('mozilla:testenv', 'unit-test with a clean-profiled Firefox open', (options) ->
    invoke('mozilla')
    require('timers').setTimeout( # workaround, it seems cake doesn't have a invokeSync
        () ->
            exec('cfx run -g testenv')
        500
    )
)

task('chromium', 'build crx for Chromium-based', (options) ->
    console.error('Building failed: Chromium is not supported for now.')
)