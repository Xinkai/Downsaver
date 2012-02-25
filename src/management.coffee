"use strict"

SIMPLE_STORAGE = require("simple-storage")
XPCOM = require('xpcom')
MOZILLA = require('mozilla')
FILE = require('file')

# Define the data structure of Task
class TaskObject
    constructor: (@filename, @originTitle, @mediaURL, @originURL, @iframeURL) ->
        @addTime = new Date()

# The values of the following keys are allowed to change after their creation.
ChangingAllowedKeys = [
    'filename'
    'status'
]

getNewUUID = () ->
    return XPCOM.makeUuid().toString()

getTaskById = (id) ->
    return SIMPLE_STORAGE.storage.tasks[id]

setTaskPropById = (id, detail) ->
    task = getTaskById(id)
    if task
        changed = false
        for key, value of detail
            if key in ChangingAllowedKeys
                changed = true
                changed[key] = value
        if changed
            SIMPLE_STORAGE.storage.tasks[id] = task
            return true
    else
        console.error("Task not found by ID: #{id}")
    return false

RunningListeners = {}
exports.createTask = (loadContext, extName) ->
    title = loadContext.associatedWindow.document.title
    filenameStem = getSuggestedFilenameStem(title)
    task = new TaskObject({
        title: title
        id: getNewUUID()
    })
    number = 1
    firstHalf = "#{MOZILLA.saveTo}#{MOZILLA.PLATFORM_SLASH}#{filenameStem}"
    secondHalf = ".#{extName}"

    while true
        if number++ is 1
            filePathName = firstHalf + secondHalf
            if not FILE.exists(filePathName)
                break
        else
            filePathName = firstHalf + " - Part #{number}" + secondHalf
            if not FILE.exists(filePathName)
                break

    return {
        task: task
        file: FILE.open(filePathName, "wb")
    }

getSuggestedFilenameStem = (originalTitle) ->
    return originalTitle.replace(/[\\/:*?"<>|]/g, " ").split(" ").join(" ")

