Firebase = require("firebase")
Fire = new Firebase(process.env.fire_url)
Fire.auth(process.env.firebase_secret)
moment = require("moment")


ref = Fire.child("heartbeat")

ref.on "value", ->

heartbeat = ->
  time = Date.now()
  ref.child("heartbeat").set time, ->
    console.log "Tick, #{moment(time).format('MMMM Do YYYY, h:mm:ss a')}"

setInterval heartbeat, 30*1000
heartbeat()