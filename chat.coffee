Messages = new Meteor.Collection("messages")


if (Meteor.is_client)
  Template.chatroom.events =
    'click #submit': ->
      Messages.insert
        'from': 'me'
        'text': $('#input').val()

  frag = Meteor.ui.render ->
    Template.chatroom
      'messages': Messages.find()

  $(document).ready ->
    document.body.appendChild(frag)

    
#if (Meteor.is_server)
#  Meteor.startup ->
#   code to run on server at startup
