"use strict"

$("div").click( () ->     # workaround for https://bugzil.la/638142
    self.port.emit("newItem", {
        "title": "This one isn't gonna saved."
        "status": "discard"
    })
    self.port.emit("newItem", {
        "title": "This one is already saved."
        "status": "saved"
    })
    self.port.emit("newItem", {
        "title": "This one is being saved."
        "status": "saving"
    })
)