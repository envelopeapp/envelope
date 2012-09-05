window.Envelope =
  Models: {}
  Collections: {}
  Helpers: {}
  Views: {}
  Routers: {}
  init: ->
    new Envelope.Routers.Accounts()
    Backbone.history.start(pushState: true)

$(document).ready ->
  Envelope.init()

#
# We need to add authentication to each Backbone request, so
# it makes sense to do it in the ajaxSetup method. Rails will
# prefix and capitalize these headers as:
#
#    HTTP_ACCESS_KEY
#    HTTP_SECRET_TOKEN
#
# We also always want JSON
#
$.ajaxSetup
  beforeSend: (xhr, settings) ->
    return if settings.crossDomain

    # TODO: hook this up to the Session model
    accessKey = 'jnBUGGEEaJVrAm9fHP4tDw'
    secretToken = 'GYscYWkzovwmK3Iil5aFPg'

    xhr.setRequestHeader 'access_key', accessKey
    xhr.setRequestHeader 'secret_token', secretToken

    # Always request JSON
    xhr.setRequestHeader 'Accept', 'application/json'
