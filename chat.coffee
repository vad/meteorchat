Messages = new Meteor.Collection("messages")


if (Meteor.is_client)
  nick = 'User' + Math.floor(Math.random()*1000)
  $input = null

  insert_message = ->
    Messages.insert
      'from': nick
      'text': $input.val()

    $input.val('')

  Template.chatroom.events =
    'click #submit': insert_message
    'keydown #input': (event) ->
      if event.which is 13
        insert_message()
        event.stopPropagation()

  frag = Meteor.ui.render ->
    Template.chatroom
      'messages': Messages.find()


  Meteor.startup ->
    document.body.appendChild(frag)
    $input = $('#input')


#if (Meteor.is_server)
#  Meteor.startup ->
#   code to run on server at startup
