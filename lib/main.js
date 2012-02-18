/**
 * Downsaver makes a browser save files as them being loaded.
 * Author: Xinkai Chen
 */


"use strict";

const OBSERVER = require("observer-service"),
    {Cc, Ci, Cu, Cr} = require("chrome"),
    FILE = require("file"),
    STORAGE = require("simple-storage"),
    RUNTIME = require("runtime"),
    {_} = require("underscore.js"),
    SELF = require("self");

SELF.name = "Downsaver";
SELF.version = "Alpha";

const ContentTypes = {
    "audio/basic": ["???", "Mulaw Audio"],
    "audio/L24": ["???", "24bit Linear PCM audio at 8-48kHz, 1-N channels"],
    "audio/mp4": ["mp4", "MP4 Audio"],
    "audio/mpeg": ["mp3", "MP3/MPEG Audio"],
    "audio/ogg": ["ogg", "OGG Audio"],
    "audio/vorbis": ["???", "Vorbis Audio"],
    "audio/x-ms-wma": ["wma", "Windows Media Audio"],
    "audio/x-ms-wax": ["wax", "Windows Media Audio Redirector"],
    "audio/vnd.rn-realaudio": ["ra", "Real Audio"],
    "audio/vnd.wave": ["wav", "Wave Audio"],
    "audio/webm": ["webm", "WebM Audio"],

    "video/mpeg": ["mpeg", "MPEG Video"],
    "video/mp4": ["mp4", "MP4 Video"],
    "video/ogg": ["ogg", "OGG Video"],
    "video/quicktime": ["mov", "QuickTime Video"],
    "video/webm": ["webm", "WebM Video"],
    "video/x-ms-wmv": ["wmv", "Windows Media Video"],

    "video/x-flv": ["flv", "Flash Video"],
    "video/3gpp": ["3gp", "3GP Video]"],
    "video/x-m4v": ["m4v", "M4V Video"]
};

const CT = {
    "EXT": 0,
    "Description": 1
};

var DownloadParts = {};
function getPartialNameFor(filenameStem) {
    if (filenameStem in DownloadParts) {
        DownloadParts[filenameStem] += 1;
    } else {
        DownloadParts[filenameStem] = 1;
    }
    return (DownloadParts[filenameStem] == 1) ?
        filenameStem :
        [filenameStem, " (", DownloadParts[filenameStem], ")"].join("");
}

/**
 * otherwise can be either a default value or a function that yields default.
 * If key is not found, then this default value will also be saved.
 */

function getOption(key, otherwise) {
    var value = STORAGE.storage[key];
    if (value === undefined) {
        switch (typeof otherwise) {
            case "undefined":
                console.error("Downsaver: option '" + key + "' is not present, and default value is not given.");
                break;
            case "function":
                value = otherwise();
                STORAGE.storage[key] = value;
                break;
            default:
                value = otherwise;
                STORAGE.storage[key] = value;
                break;
        }
    }
    return value;
}
const slash = RUNTIME.OS === "WINNT" ? "\\" : "/";

const osJoin = function(dir, file) {
    return dir + slash + file;
};

var saveTo = getOption("saveTo", function() {
    var FolderPicker = Cc["@mozilla.org/filepicker;1"]
        .createInstance(Ci.nsIFilePicker);
    var wm = Cc["@mozilla.org/appshell/window-mediator;1"]
        .getService(Ci.nsIWindowMediator);
    var browserWindow = wm.getMostRecentWindow("navigator:browser");

    FolderPicker.init(browserWindow, "Where do you want the files to be saved?",
        Ci.nsIFilePicker.modeGetFolder);
    var result = FolderPicker.show();
    if (result === Ci.nsIFilePicker.returnOK) {
        return FolderPicker.file.path;
    } else {
        return;
    }
});


exports.main = function() {
    console.log("DWARF LOADS...");

    var StreamListener = function(filenameStem, extName) {
        this.filenameStem = filenameStem;
        this.extName = extName;
        this.file = undefined;
    };

    StreamListener.prototype = {
        onStartRequest: function(aRequest, aContext) {
            console.log("About to download");

            this.oldListener.onStartRequest(aRequest, aContext);
        },
        onDataAvailable: function(aRequest, aContext, aInputStream, aOffset, aCount) {
            console.log("Data is available.");

            var binaryInputStream = Cc["@mozilla.org/binaryinputstream;1"]
                .createInstance(Ci.nsIBinaryInputStream);
            var storageStream = Cc["@mozilla.org/storagestream;1"]
                .createInstance(Ci.nsIStorageStream);
            var binaryOutputStream = Cc["@mozilla.org/binaryoutputstream;1"]
                .createInstance(Ci.nsIBinaryOutputStream);

            if (this.file === undefined) {
                var filename = [getPartialNameFor(this.filenameStem),
                    this.extName].join(".");
                this.file = FILE.open(osJoin(saveTo, filename),
                    "wb");
            }

            binaryInputStream.setInputStream(aInputStream);

            storageStream.init(8192, aCount, null);
            binaryOutputStream.setOutputStream(storageStream.getOutputStream(0));

            // Copy received data as they come.
            var data = binaryInputStream.readBytes(aCount);

            binaryOutputStream.writeBytes(data, aCount);
            this.file.write(data);
            this.oldListener.onDataAvailable(aRequest, aContext,
                storageStream.newInputStream(0), aOffset, aCount);
        },
        onStopRequest: function(aRequest, aContext, aStatusCode) {
            if (aStatusCode === Cr.NS_OK) {
                console.log("Request ended");
            } else {
                console.error("Request Failed: ", aStatusCode);
            }
            if (this.file) {
                this.file.close();
            }
            this.oldListener.onStopRequest(aRequest, aContext, aStatusCode);
        }
    };


    // Try Content Type First    
    OBSERVER.add("http-on-examine-response", function(aSubject, data) {
        aSubject.QueryInterface(Ci.nsIHttpChannel);

        try {
            var content_type = aSubject.getResponseHeader("Content-Type");
            if (content_type in ContentTypes) {
                aSubject.QueryInterface(Ci.nsITraceableChannel);

                var loadContext;
                try {
                    loadContext =
                        aSubject.QueryInterface(Ci.nsIChannel)
                            .notificationCallbacks
                            .getInterface(Ci.nsILoadContext);
                } catch (ex) {
                    console.log(ex);
                    try {
                        loadContext =
                            aSubject.loadGroup.notificationCallbacks
                                .getInterface(Ci.nsILoadContext);
                    } catch (ex) {
                        console.log(ex);
                        loadContext = null;
                    }
                }

                var filename = loadContext.associatedWindow.document.title
                    .replace(/[\\/:*?"<>|]/g, " ").split(" ").join(" ");

                var listener = new StreamListener(filename,
                    ContentTypes[content_type][CT.EXT]);

                listener.oldListener = aSubject.setNewListener(listener);
            }
        } catch(err) {
            if (err.name === "NS_ERROR_NOT_AVAILABLE") {} else {
                console.error("Downsaver: ", err.message);
            }
        }
    });

    // Try Extension Name Second
};