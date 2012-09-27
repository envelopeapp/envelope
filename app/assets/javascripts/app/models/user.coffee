class Envelope.User extends Spine.Model
  @configure 'User', 'first_name', 'last_name', 'username', 'email_address'

  @extend Spine.Model.Ajax
  @url: '/api/users'

  name: ->
    [first_name, last_name].join(' ')
