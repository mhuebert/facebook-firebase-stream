extend = (destination, objects...) ->
  for object in objects
    for key, value of object
      destination[key] = value
  return 

@denormalize = (stream) ->
  updates = []
  for changesContainer in stream.entry
    add1 = {}
    for key, val of stream
      add1["___"+key] = stream[key] if key != "entry"
      add2 = {}
    for change in changesContainer.changes
      for key, val of changesContainer
        add2["__"+key] = changesContainer[key] if key != "changes"
      add3 = {}
      for key, val of change
        add3["_"+key] = change[key] if key != "value"
      update = change.value
      extend update, add3, add2, add1
      updates.push update
  updates