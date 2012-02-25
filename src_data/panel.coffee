"use strict"

_.templateSettings =
    interpolate: /\{\{(.+?)\}\}/g

self.port.on("newItem", (detail) -> # detail defines what the item is
    console.log("newItem triggered.")
    template = _.template($("#newItemTemplate").html())
    $("#itemsContainer").prepend(template(detail))
)