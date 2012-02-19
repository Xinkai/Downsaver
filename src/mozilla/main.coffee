#
# Downsaver makes a browser automatically save video/audio/image or any other online resources to the disk while they being loaded.
# Author: Xinkai Chen

"use strict"

OBSERVER = require("observer-service")
{Cc, Ci, Cu, Cr} = require("chrome")

FILE = require("file")
STORAGE = require("simple-storage")
RUNTIME = require("runtime")
{_} = require("underscore.js")
SELF = require("self")

SELF.name = "Downsaver"
SELF.version = "Alpha"

ContentTypes =
    "audio/basic": ["???", "Mulaw Audio"]
    "audio/L24": ["???", "24bit Linear PCM audio at 8-48kHz, 1-N channels"]
    "audio/mp4": ["mp4", "MP4 Audio"]
    "audio/mpeg": ["mp3", "MP3/MPEG Audio"]
    "audio/ogg": ["ogg", "OGG Audio"]
    "audio/vorbis": ["???", "Vorbis Audio"]
    "audio/x-ms-wma": ["wma", "Windows Media Audio"]
    "audio/x-ms-wax": ["wax", "Windows Media Audio Redirector"]
    "audio/vnd.rn-realaudio": ["ra", "Real Audio"]
    "audio/vnd.wave": ["wav", "Wave Audio"]
    "audio/webm": ["webm", "WebM Audio"]

    "video/mpeg": ["mpeg", "MPEG Video"]
    "video/mp4": ["mp4", "MP4 Video"]
    "video/ogg": ["ogg", "OGG Video"]
    "video/quicktime": ["mov", "QuickTime Video"]
    "video/webm": ["webm", "WebM Video"]
    "video/x-ms-wmv": ["wmv", "Windows Media Video"]
    "video/flv": ["flv", "Flash Video"]

    "video/x-flv": ["flv", "Flash Video"]
    "video/3gpp": ["3gp", "3GP Video"]
    "video/x-m4v": ["m4v", "M4V Video"]

CT =
    "EXT": 0
    "Description": 1

DownloadParts = {}
getPartialNameFor = (filenameStem) ->
    if filenameStem of DownloadParts
        DownloadParts[filenameStem] += 1
    else
        DownloadParts[filenameStem] = 1
    return if DownloadParts[filenameStem] is 1 then filenameStem else "#{filenameStem} (#{DownloadParts[filenameStem]})"

# otherwise can be either a default value or a function that yields default.
# If key is not found, then this default value will also be saved.

getOption = (key, otherwise) ->
    value = STORAGE.storage[key]
    if value is undefined
        switch typeof(otherwise)
            when "undefined"
                console.error("Downsaver: option #{key} is not present, and default value is not given.")

            when "function"
                value = otherwise()
                STORAGE.storage[key] = value

            else
                value = otherwise
                STORAGE.storage[key] = value
    return value

slash = if RUNTIME.OS is "WINNT" then "\\" else "/"

osJoin = (dir, file) ->
    return dir + slash + file


saveTo = getOption("saveTo", () ->
    FolderPicker = Cc["@mozilla.org/filepicker;1"]
                        .createInstance(Ci.nsIFilePicker)
    wm = Cc["@mozilla.org/appshell/window-mediator;1"]
                        .getService(Ci.nsIWindowMediator)
    browserWindow = wm.getMostRecentWindow("navigator:browser")

    FolderPicker.init(browserWindow, "Where do you want the files to be saved?",
                Ci.nsIFilePicker.modeGetFolder)

    result = FolderPicker.show()
    if result is Ci.nsIFilePicker.returnOK
        return FolderPicker.file.path
    else
        return
)


exports.main = () ->
    console.log("Downsaver Loads...")

    StreamListener = (filenameStem, extName) ->
        @filenameStem = filenameStem
        @extName = extName
        @file = undefined


    StreamListener.prototype =
        onStartRequest: (aRequest, aContext) ->
            console.log("About to download")
            @oldListener.onStartRequest(aRequest, aContext)

        onDataAvailable: (aRequest, aContext, aInputStream, aOffset, aCount) ->
            console.log("Data is available.")

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
                console.log("Request ended")
            else
                console.error("Request Failed: ", aStatusCode)

            if @file
                @file.close()
            @oldListener.onStopRequest(aRequest, aContext, aStatusCode)



    # Try Content Type First
    OBSERVER.add("http-on-examine-response", (aSubject, data) ->
        aSubject.QueryInterface(Ci.nsIHttpChannel)

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
                catch ex
                    console.log(ex)
                    try
                        loadContext =
                            aSubject.loadGroup.notificationCallbacks
                                    .getInterface(Ci.nsILoadContext)
                    catch ex
                        console.log(ex)
                        loadContext = null

                filename = loadContext.associatedWindow.document.title
                        .replace(/[\\/:*?"<>|]/g, " ").split(" ").join(" ")

                listener = new StreamListener(filename, ContentTypes[content_type][CT.EXT])

                listener.oldListener = aSubject.setNewListener(listener)

        catch err
            if err.name is "NS_ERROR_NOT_AVAILABLE"

            else
                console.error("Downsaver: ", err.message)

    # TODO: Try Extension Name Second
    )