"use strict"

main = require("mozilla")
SIMPLE_PREFS = require('simple-prefs')
PRIVATE_BROWSING = require('private-browsing')
TIMERS = require('timers')

exports.test_test_run = (test) ->
    test.pass("Unit test running!")

exports.test_id = (test) ->
    test.assert(require("self").id.length > 0)

exports.test_extract_extension_name = (test) ->
    tests =
        "http://youtube.com:80/": null
        "https://youtube.com/watch/player.swf?id=38472": "swf"
        "https://youtube.com/watch/player.swf#id=38472.wmv": "swf"
        "https://youtube.com/watch/player.swf?id=38472&deer=horse": "swf"
        "http://235.34.52.64/cache/6.mp3": "mp3"
        "http://235.34.52.64/cache/6.4.MP3": "mp3"
        "http://235.34.52.64": null
        "http://235.34.52.64/": null
        "http://235.34.52.64/demo": null
        "http://235.34.52.64/demo.webm": "webm"
        "http://235.34.52.64:12345/demo.webm": "webm"
        "http://235.34.52.64/demo.webm/": null
        "http://235.34.52.64:12345/demo.webm/": null
        "http://youtu.be/": null
        "http://youtu.be": null
        "http://youtu.be//": null


    for testURL, extName of tests
        test.assertStrictEqual(main.extractExtensionName(testURL), extName)

exports.test_downsaver_on_off = (test) ->
    testWithSwitches = (isOff, workOnPrivateBrowsing, expects) -> # 'off' is a reserved keyword in coffee
        SIMPLE_PREFS.prefs.off = isOff
        SIMPLE_PREFS.prefs.workOnPrivateBrowsing = workOnPrivateBrowsing
        test.assertStrictEqual(main.isDownsaverOnNow(), expects)

    test.assertStrictEqual(PRIVATE_BROWSING.isActive, false)
    # Private-browsing off
    PRIVATE_BROWSING.deactivate()
    test.assertStrictEqual(PRIVATE_BROWSING.isActive, false)
    testWithSwitches(true, true, false)
    testWithSwitches(true, false, false)
    testWithSwitches(false, true, true)
    testWithSwitches(false, false, true)

    PRIVATE_BROWSING.activate()
    TIMERS.setTimeout(
        () ->
            test.assertStrictEqual(PRIVATE_BROWSING.isActive, true)
            # Private-browsing on
            testWithSwitches(true, true, false)
            testWithSwitches(true, false, false)
            testWithSwitches(false, true, true)
            testWithSwitches(false, false, false)
            test.done()
        0
    )
    test.waitUntilDone(5000)

