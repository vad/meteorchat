enable_autoscroll = true
nick = amplify.store('nick')
if not nick
  nick = 'User' + Math.floor(Math.random()*1000)
  amplify.store('nick', nick)
#  Session.set('nick', nick)
Session.set 'user_id', Meteor.uuid()
$input = null

insert_message = ->
  val = $input.val()
  $input.val('')

  if val[0] is '/'
    nick_groups = /\/nick ([a-zA-Z0-9_-]+)/.exec(val)
    if nick_groups
      nick = nick_groups[1]
      amplify.store('nick', nick)
      Connections.update {user_id: Session.get("user_id")}, {$set: {nick: nick}}
      return
    alert "Unknown command"
    return
  Messages.insert
    'from': nick
    'text': val

  $input.val('')


Template.people.is_me = (user_id) ->
  user_id is Session.get 'user_id'

Template.chatroom.embed = (text) ->
  key = ""

  if not /https?\:\/\//.test(text)
    return ''

  id_ = Meteor.uuid()
  div_id = "embed-#{id_}"

  url = text
  $.getJSON("http://api.embed.ly/1/oembed?callback=?", {
    key: key
    url: url
    maxwidth: 800
    maxheight: 300
    format: "jsonp"
  }, (data) ->
    console.log data
    $("##{div_id}").html(data.html?)
  )
  return div_id

# ping heartbeat every 5 seconds
Meteor.setInterval( ->
  Meteor.call('keepalive', Session.get('user_id'), nick)
, 1000)

Meteor.startup ->
  Meteor.subscribe("messages")
  Meteor.subscribe("open_connections")

  $input = $('#input')
  $('#submit').click insert_message

  $input.keydown (event) ->
    if event.which is 13
      insert_message()
      event.stopPropagation()

  Meteor.call('keepalive', Session.get('user_id'), nick)

  room = Meteor.ui.render ->
    Template.chatroom
      'messages': Messages.find({})

  $('.room').append(room)

  people = Meteor.ui.render ->
    Template.people
      'people': Connections.find()

  $('.people').append(people)

  $('.room').scroll (event) ->
    $room = $('.room')
    room = $room[0]
    enable_autoscroll = false
    if $room.height() is (room.scrollHeight - room.scrollTop)
      enable_autoscroll = true

  $input.focus()

  # autoscroll
  Messages.find().observe
    added: ->
      setTimeout(->
        if enable_autoscroll
          $('.room')[0].scrollByPages(100)
      , 10)
