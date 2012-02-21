#
# Downsaver saves whatever media a browser loads while it is being loaded.
# Author: Xinkai Chen

"use strict"

OBSERVER = require("observer-service")
{Cc, Ci, Cu, Cr} = require("chrome")
FILE = require("file")
RUNTIME = require("runtime")
SIMPLE_PREFS = require('simple-prefs')
PRIVATE_BROWSING = require('private-browsing')
MEDIA_RULES = require('media-rules.js')
{_} = require("underscore.js")



DownloadParts = {}
getPartialNameFor = (filenameStem) ->
    if filenameStem of DownloadParts
        DownloadParts[filenameStem] += 1
    else
        DownloadParts[filenameStem] = 1
    return if DownloadParts[filenameStem] is 1 then filenameStem else "#{filenameStem} (#{DownloadParts[filenameStem]})"


PLATFORM_SLASH = if RUNTIME.OS is "WINNT" then "\\" else "/"

osJoin = (dir, file) ->
    return dir + PLATFORM_SLASH + file

getSaveTo = () ->
    saveTo_fromPrefs = SIMPLE_PREFS.prefs.saveTo
    if not saveTo_fromPrefs
        FolderPicker = Cc["@mozilla.org/filepicker;1"]
                            .createInstance(Ci.nsIFilePicker)
        wm = Cc["@mozilla.org/appshell/window-mediator;1"]
                            .getService(Ci.nsIWindowMediator)
        browserWindow = wm.getMostRecentWindow("navigator:browser")

        FolderPicker.init(browserWindow, "Where to save the files",
                                    Ci.nsIFilePicker.modeGetFolder)

        result = FolderPicker.show()
        if result is Ci.nsIFilePicker.returnOK
            SIMPLE_PREFS.prefs.saveTo = FolderPicker.file.path
        return getSaveTo()
    else
        # TODO: verifry the validness of the saveTo path
        return saveTo_fromPrefs

saveTo = getSaveTo()


isDownsaverOnNow = () ->
    if SIMPLE_PREFS.prefs.off
        return false
    if (not SIMPLE_PREFS.prefs.workOnPrivateBrowsing) and PRIVATE_BROWSING.isActive
        return false
    return true


httpObserver = (aSubject, data) ->
    aSubject.QueryInterface(Ci.nsIHttpChannel)

    if not isDownsaverOnNow()
        return

    # TODO: check simple-prefs: saveByDefault

    # TODO: Try Extension Name First

    # Try Content Type Second
    try
        content_type = aSubject.getResponseHeader("Content-Type")
        if content_type of MEDIA_RULES.ContentTypes
            extensionName = MEDIA_RULES.ContentTypes[content_type]
            aSubject.QueryInterface(Ci.nsITraceableChannel)

            loadContext = undefined
            try
                loadContext =
                    aSubject.QueryInterface(Ci.nsIChannel)
                            .notificationCallbacks
                            .getInterface(Ci.nsILoadContext)
            catch err2
                console.log("Downsaver: ", err2)
                try
                    loadContext =
                        aSubject.loadGroup.notificationCallbacks
                                .getInterface(Ci.nsILoadContext)
                catch err3
                    console.error("Downsaver: ", err3)
                    loadContext = null

            filename = loadContext.associatedWindow.document.title
                                    .replace(/[\\/:*?"<>|]/g, " ").split(" ").join(" ")

            listener = new StreamListener(filename, extensionName)

            listener.oldListener = aSubject.setNewListener(listener)

    catch err
        if err.name is "NS_ERROR_NOT_AVAILABLE"

        else
            console.error("Downsaver: ", err.message)

    # TODO: Try Custom Filters

class StreamListener
    constructor: (@filenameStem, @extName) ->
        @file = undefined

    onStartRequest: (aRequest, aContext) ->
        console.log("Downsaver: about to download")
        @oldListener.onStartRequest(aRequest, aContext)

    onDataAvailable: (aRequest, aContext, aInputStream, aOffset, aCount) ->
        console.log("Downsaver: data is available")

        binaryInputStream = Cc["@mozilla.org/binaryinputstream;1"]
                                .createInstance(Ci.nsIBinaryInputStream)
        storageStream = Cc["@mozilla.org/storagestream;1"]
                                .createInstance(Ci.nsIStorageStream)
        binaryOutputStream = Cc["@mozilla.org/binaryoutputstream;1"]
                                .createInstance(Ci.nsIBinaryOutputStream)

        if @file is undefined
            filename = "#{getPartialNameFor(@filenameStem)}.#{@extName}"
            @file = FILE.open(osJoin(saveTo, filename), "wb")

        binaryInputStream.setInputStream(aInputStream)
        storageStream.init(8192, aCount, null)
        binaryOutputStream.setOutputStream(storageStream.getOutputStream(0))

        # Copy received data as they come.
        data = binaryInputStream.readBytes(aCount)
        binaryOutputStream.writeBytes(data, aCount)
        @file.write(data)
        @oldListener.onDataAvailable(aRequest, aContext,
            storageStream.newInputStream(0), aOffset, aCount)

    onStopRequest: (aRequest, aContext, aStatusCode) ->
        if aStatusCode is Cr.NS_OK
            console.log("Downsaver: request ended")
        else
            console.error("Downsaver: request failed - ", aStatusCode)

        if @file
            @file.close()
        @oldListener.onStopRequest(aRequest, aContext, aStatusCode)


exports.main = (options, callbacks) ->
    console.log("Downsaver Loads, reason: ", options.loadReason)
    OBSERVER.add("http-on-examine-response", httpObserver)


exports.onUnload = (reason) ->
    switch reason
        when "uninstall"
            console.log("Downsaver uninstalled")
        when "disable"
            console.log("Downsaver disabled")
            OBSERVER.remove("http-on-examine-response", httpObserver)
        when "shutdown"
            console.log("Downsaver shutdown")
        when "upgrade"
            console.log("Downsaver upgraded")
        when "downgrade"
            console.log("Downsaver downgraded")

exports.isDownsaverOnNow = isDownsaverOnNow