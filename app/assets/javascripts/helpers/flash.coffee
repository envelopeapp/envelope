#
# This class is used for managing flash messages
#
#   Flash.notice(message)
#   Flash.alert(message)
#   Flash.success(message)
#   Flash.info(message)
#   ...
#
class Flash
  @notice = (message) =>
    @_render('notice', message)

  @alert = (message) =>
    @_render('alert', message)

  @success = (message) =>
    @_render('success', message)

  @info = (message) =>
    @_render('info', message)


  #
  # The render function is a helper function for rendering
  # flash messages or messages that come in from private_pub
  #
  @_render = (type, message) ->
    klass = switch type
      when 'notice' then 'alert'
      when 'alert' then 'alert alert-error'
      when 'success' then 'alert alert-success'
      when 'info' then 'alert alert-info'

    $flash = $('#flash')

    $flash.removeClass()
    $flash.addClass(klass)
    $flash.html(message)

    $flash.slideDown 100, ->
      unless type == 'alert'
        setTimeout =>
          $(@).slideUp 250
        , 5000

window.Flash = Flash