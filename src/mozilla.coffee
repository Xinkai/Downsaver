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
{_} = require("underscore.js")

ExtensionNames =
    "ogg": "Vorbis/OGG Media"
    "oga": "Vorbis/OGG Media"
    "mp1": "MP1 Audio"
    "mp2": "MP2 Audio"
    "mp3": "MP3 Audio"
    "mp4": "MP4 Media"
    "avi": "AVI Video"
    "mkv": "MKV Video"
    "rmvb": "RMVB Video"
    "rm": "RM Video"
    "ra": "Real Audio"
    "webm": "WebM Media"
    "wav": "Wave Audio"
    "wave": "Wave Audio"
    "mov": "QuickTime Video"
    "qt": "QuickTime Video"
    "mpe": "MPEG Media"
    "mpg": "MPEG Media"
    "mpeg": "MPEG Media"
    "wma": "Windows Media Audio"
    "wax": "Windows Media Audio Redirector"
    "m4v": "M4V Video"
    "3gp": "3GP Video"
    "flv": "Flash Video"
    "asf": "ASF Video"
    "f4v": "F4V"
    "vob": "VOB"
    "flac": "FLAC Audio"
    "aac": "AAC Audio"
    "mmf": "MMF"
    "amr": "AMR"
    "m4a": "M4A Audio"
    "ape": "APE Audio"
    "wmv": "Windows Media Video"
    "au": "BASIC Audio"
    "snd": "BASIC Audio"
    "midi": "MIDI Audio"
    "mid": "MIDI Audio"
    "aiff": "AIFF Audio"
    "aif": "AIFF Audio"
    "aifc": "AIFF Audio"
    "vdo": "VDO Streaming Video"
    "vivo": "VIVO Streaming Video"
    "viv": "VIVO Streaming Video"
    "movie": "SGI Movieplayer Format"
    "voc": "Voice Audio"

ContentTypes =
    "audio/basic": "au"
    # "audio/L24": ["???", "24bit Linear PCM audio at 8-48kHz, 1-N channels"]
    "audio/mp4": "mp4"
    "audio/mpeg": "mp3"
    "audio/x-mpeg": "mp3"
    "audio/x-pn-realaudio": "ra"
    "audio/x-voice": "voc"
    "audio/x-wav": "wav"
    "audio/wav": "wav"
    "audio/ogg": "ogg"
    "audio/vorbis": "ogg"
    "audio/x-ms-wma": "wma"
    "audio/x-ms-wax": "wax"
    "audio/vnd.rn-realaudio": "ra"
    "audio/vnd.wave": "wav"
    "audio/webm": "webm"

    "application/x-midi": "midi"
    "audio/midi": "midi"
    "audio/x-aiff": "aiff"

    "video/mpeg": "mpeg"
    "video/msvideo": "avi"
    "video/mp4": "mp4"
    "video/ogg": "ogg"
    "video/quicktime": "mov"
    "video/webm": "webm"
    "video/x-ms-wmv": "wmv"
    "video/flv": "flv"
    "video/x-flv": "flv"
    "video/3gpp": "3gp"
    "video/x-m4v": "m4v"
    "video/vdo": "vdo"
    "video/vivo": "vivo"
    "video/x-sgi-movie": "movie"


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
    else
        if (not SIMPLE_PREFS.prefs.workOnPrivateBrowsing) and PRIVATE_BROWSING.isActive
            return false
        return true


extractExtensionName = (URI) ->
    URI = URI.toLowerCase()

    # Cut off "?", "#"
    questionMarkIndex= URI.indexOf("?")
    if questionMarkIndex >= 0
        URI = URI.substr(0, questionMarkIndex)

    hashMarkIndex = URI.indexOf("#")
    if hashMarkIndex >= 0
        URI = URI.substr(0, hashMarkIndex)

    fractions = URI.split("/")
    if fractions.length > 3 # ["http:", "", "youtube.com", ....]
        extensionNameFractions = fractions.pop().split(".")
        if extensionNameFractions.length > 1 # http://test.com/demo
            return extensionNameFractions.pop()

    return null

addHttpObserver = (aSubject, data) ->
    aSubject.QueryInterface(Ci.nsIHttpChannel)

    if not isDownsaverOnNow()
        return

    # TODO: check simple-prefs: saveByDefault

    # TODO: Try Extension Name First

    # Try Content Type Second
    try
        content_type = aSubject.getResponseHeader("Content-Type")
        if content_type of ContentTypes
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
                    console.log("Downsaver: ", err3)
                    loadContext = null

            filename = loadContext.associatedWindow.document.title
                                    .replace(/[\\/:*?"<>|]/g, " ").split(" ").join(" ")

            listener = new StreamListener(filename, ContentTypes[content_type])

            listener.oldListener = aSubject.setNewListener(listener)

    catch err
        if err.name is "NS_ERROR_NOT_AVAILABLE"

        else
            console.error("Downsaver: ", err.message)

    # TODO: Try Custom Filters


exports.main = (options, callbacks) ->
    console.log("Downsaver Loads, reason: ", options.loadReason)

    StreamListener = (filenameStem, extName) ->
        @filenameStem = filenameStem
        @extName = extName
        @file = undefined


    StreamListener.prototype =
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


    OBSERVER.add("http-on-examine-response", addHttpObserver)

exports.onUnload = (reason) ->
    switch reason
        when "uninstall"
            console.log("Downsaver uninstalled")
        when "disable"
            console.log("Downsaver disabled")
            OBSERVER.remove("http-on-examine-response", addHttpObserver);
        when "shutdown"
            console.log("Downsaver shutdown")
        when "upgrade"
            console.log("Downsaver upgraded")
        when "downgrade"
            console.log("Downsaver downgraded")

exports.extractExtensionName = extractExtensionName
exports.isDownsaverOnNow = isDownsaverOnNow
exports.ContentTypes = ContentTypes
exports.ExtensionNames = ExtensionNames