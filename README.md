# firebase-facebook-stream

A single-purpose server that listens for updates from Facebook's [Real-Time API](https://developers.facebook.com/docs/graph-api/real-time-updates/v2.0), transforms the update into something manageable, and saves them into Firebase, sorted in descending order by time.

## Denormalization

A single event from Facebook's real-time API looks like this:

```(js)
{
    "entry": [
        {
            "changes": [
                {
                    "field": "feed",
                    "value": {
                        "item": 
                        "post_id": 1445349762408605",
                        "sender_id": 
                        "verb": "add"
                    }
                }
            ],
            "id": "1445183662425215",
            "time": 1406879102
        }
    ],
    "object": "page"
}
```

Multiple objects may be present at varying levels of the hierarchy.

After denormalization, the same update looks like:

```(js)
{
    "item": "status",
    "post_id": "1445183662425215_1445349762408605",
    "sender_id": 
    "verb": "add",
    "_field": "feed",
    "__id": "1445183662425215",
    "__time": 1406879102,
    "___object": "page"
}
```

This is what I save to Firebase, as an alternative to scooping out my eyeballs and purging my brain.

An underscore prefix on a field denotes that it was inherited from a parent level in the hierarchy.

### Notes

* if you adapt this for your own purposes, you'll want to remove the line:

    ```if item.verb == "add" and item.hasOwnProperty("post_id")```

(Or modify it to suit your own needs - FB's real-time update API isn't very granular, so there's a good chance you won't want to keep everything they send.)

* I've only used this with a "feed" subscription - I'm not sure what other subscription payloads look like.