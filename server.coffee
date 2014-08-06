express = require("express")
Firebase = require("firebase")
hash = require('object-hash')
url = require('url')
bodyParser = require('body-parser')
methodOverride = require("method-override")
{flatten} = require("./utils")
morgan = require("morgan")


# For process.env variables with a REPL:
# env = require('node-env-file')
# env('./.env')


Firebase = new Firebase(process.env.fire_url)
Firebase.auth(process.env.firebase_secret)

app = express()
app.use morgan('dev')
app.use methodOverride()
app.use bodyParser.json()
# app.use bodyParser.urlencoded(extended: true)

# Receive updates from Facebook
app.post "/webhooks/page-feed", (req, res) ->
  items = flatten(req.body)
  if items.length == 0
    res.status(200).send "Thanks"
    return
  for item in items
    # Only save new posts (not comments, or changes to old posts)
    if item.verb == "add" and item.hasOwnProperty("post_id") and !item.hasOwnProperty("comment_id")
      # Items are sorted by key. We want descending order by time,
      # along with a hash of the item itself, so that we never add the same item twice.
      time = 10000000000 - parseInt item["__time"]
      Firebase.child("stream/#{time+hash.MD5(item)}").update item, (err) ->
        if err
          res.status(500).send "Error"
          console.log "Error", err
          return
        res.status(200).send "Thanks"
        return
    else
      res.status(200).send "Thanks"
      return
# REQUIRED - respond to Facebook's verification GET request
app.get "/webhooks/page-feed", (req, res) ->
  query = url.parse(req.url, true).query
  if query["hub.verify_token"] != process.env["verify_token"]
    console.log "Invalid verify_token from Facebook"
    res.send "Incorrect token", 400
    return
  res.status(200).send query["hub.challenge"]

app.all "/", (req, res) ->
  res.status(200).send "<h1>Hello, world.</h1>"

app.listen(process.env.PORT || 3000)

