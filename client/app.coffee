Colors = new Meteor.Collection 'colors'
Meteor.subscribe('colors')
Router.configure layoutTemplate: 'layout'
Router.map -> 
  this.route 'home', path: '/'
  this.route 'about' 
  this.route 'help'
  this.route 'profile'
  this.route 'settings'

Accounts.ui.config passwordSignupFields: 'USERNAME_AND_EMAIL'
Template.hello.events 'click input': -> console.log 'You pressed the button!'
Template.color_list.colors = -> Colors.find {}, sort: likes: -1, name: 1
Template.color_list.events 'click button': -> Colors.update Session.get( 'session_color' ), $inc: likes: 1 
Template.color_info.events 'click': -> Session.set 'session_color', this._id
Template.color_info.maybe_selected = -> if Session.equals 'session_color', this._id then 'selected' else 'not_selected'

