Spine.Controller.include
  view: (name) ->
    JST["app/views/#{name}"]

  modal: (template) ->
    modal = $('#modal')
    modal.html(template)
    modal.modal('show')
