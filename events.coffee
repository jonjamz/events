# Note: could optionally persist things to MongoDB or Redis

Meteor.startup ->
  Events.channels.create('fun-times').events [
    'drank-a-beer'
    'played-a-drinking-game'
    'drank-scotch'
    'played-dota'
  ]

  Events.on 'fun-times', 'drank-a-beer', (type) ->
    console.log "You drank a #{type} beer"

  Events.on 'fun-times', 'drank-a-beer', (type) ->
    console.log "You enjoyed a #{type} beer"

  Events.publish 'fun-times', 'drank-a-beer', 'heineken'
  Events.publish 'fun-times', 'drank-a-beer', 'stone smoked porter'

  Events.channels.create('sad-times').events [
    'cried'
  ]

  Events.on 'sad-times', 'cried', (how) ->
    console.log "You are sad, so you cried #{how}"

  Events.publish 'sad-times', 'cried', 'loudly'

Events = do ->

  _channels = {}

  _safeWarn = (message) ->
    if console?.warn?
      console.warn message

  # Setup
  # -----

  createChannel = (name) ->
    if !_channels[name]
      _channels[name] = {}
    else
      _safeWarn "Channel #{name} already exists!"

    # Return an easy chain method for adding events to the new channel
    return {
      events: (events) ->
        for event in events
          createEvent(event, name) # Using channel name passed into createChannel
    }

  createEvent = (name, channel) ->
    if !_channels[channel]
      _safeWarn "Channel #{channel} doesn't exist yet!"
    else if !_channels[channel][name]
      _channels[channel][name] = []
    else
      _safeWarn "Event #{name} in channel #{channel} already exists!"

  # Subscribers
  # -----------

  # Events.on('channel-name', event, (data) -> )
  subscribe = (channel, event, handler) ->
    if !_channels[channel]
      createChannel(channel)
    if !_channels[channel][event]
      createEvent(event, channel)
    _channels[channel][event].push handler # returns index

  # Events.off('channel-name', event, index)
  # Use index that was returned from .on()
  unsubscribe = (channel, event, index) ->
    if channels[channel] and channels[channel][event]
      _channels[channel][event][index] = -> # convert to no-op

  # Publishers
  # ----------

  # Events.publish('channel-name', event, data)
  # Simply publish an event with data
  publish = (channel, event, data) ->
    for handler in _channels[channel][event]
      handler(data)

  {
    channels:
      create: createChannel
      createEvent: createEvent
    on: subscribe
    off: unsubscribe
    publish: publish
  }