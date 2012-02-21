"use strict"

exports.ExtensionNames =
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
    "hlv": "Unknown Format Video"

exports.ContentTypes =
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

exports.extractExtensionName = (URI) ->
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