"use strict"

MEDIA_RULES = require('media-rules')

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

    for testURI, extName of tests
        test.assertStrictEqual(MEDIA_RULES.extractExtensionName(testURI), extName)


exports.test_every_contentType_has_extension = (test) ->
    for contentType, extName of MEDIA_RULES.ContentTypes
        test.assert(extName of MEDIA_RULES.ExtensionNames, "Extension Name '#{extName}' is not in ExtensionNames.")