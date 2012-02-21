"use strict"

MOZILLA = require("mozilla")
SIMPLE_PREFS = require('simple-prefs')
PRIVATE_BROWSING = require('private-browsing')
TIMERS = require('timers')


exports.test_downsaver_on_off = (test) ->
    testWithSwitches = (isOff, workOnPrivateBrowsing, expects) -> # 'off' is a reserved keyword in coffee
        SIMPLE_PREFS.prefs.off = isOff
        SIMPLE_PREFS.prefs.workOnPrivateBrowsing = workOnPrivateBrowsing
        test.assertStrictEqual(MOZILLA.isDownsaverOnNow(), expects)

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
            PRIVATE_BROWSING.deactivate()
            test.done()
        0
    )
    test.waitUntilDone(5000)

