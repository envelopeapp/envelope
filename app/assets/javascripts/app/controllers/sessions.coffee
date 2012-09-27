class Envelope.Sessions extends Spine.Controller
  events:
    'submit #login-form': 'authenticate'
    'click #logout-button': 'logout'

  elements:
    '#login-form': 'login_form'
    '.modal-body': 'modal_body'

  constructor: ->
    super
    @render()

  render: =>
    @html @view('sessions/new')(@)

  authenticate: (event) ->
    event.preventDefault()

    data =
      login: @login_form.find('input#login').val()
      password: @login_form.find('input#password').val()

    $.ajax
      type: 'POST'
      url: '/login'
      data: data
      success: (response) =>
        if response.user
          # load session
          window.current_user = new Envelope.User(response.user)
          @navigate('/home')
        else
          @_show_error(response.message)
      error: (error) =>
        @log error

  logout: ->
    $.ajax
      type: 'DELETE'
      url: '/sessions'
      success: (response) =>
        @log response
        delete window.current_user
      error: (error) =>
        @log error

  _show_error: (message) ->
    @modal_body.find('.alert').remove()
    @modal_body.prepend "<div class='alert alert-error'>#{message}</div>"
