"use strict"

exports.test_timekiller = (test) ->
    test.waitUntilDone(24 * 60 * 60 * 1000)