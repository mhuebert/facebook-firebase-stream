Firebase = require("firebase")
moment = require("moment")
rest = require("restler")
ref = new Firebase(process.env.fire_url)
ref.auth(process.env.firebase_secret)

ref.child("heartbeat").on "value", -> 

time = -> moment().format('MMMM Do YYYY, h:mm:ss a')

Cron = require("cron").CronJob

new Cron '* * * * * *', ->
  console.log "in cron", time()
  ref.child("heartbeat/internetmirror").set time()
, null, true

setInterval ->
  console.log "in timeout", time()
, 1000

# new Cron '30 * * * * *', ->
#   r = rest.get "https://#{process.env.other_app}.herokuapp.com"
#   r.on "success", (result, response) -> console.log "#{process.env.other_app} is up"
#   r.on "fail", -> handleFail
#   r.on "error", -> handleFail
# , null, true

# handleFail = -> 
#   console.log "#{process.env.other_app} is down"
#   ref.child("heartbeat/#{process.env.other_app}-down").set time()