"use strict"

main = require("mozilla")

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
        test.assertEqual(main.extractExtensionName(testURL), extName)
