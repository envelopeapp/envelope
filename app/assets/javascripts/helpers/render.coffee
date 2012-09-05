#
# This class is used for rendering objects. Everything is a class method:
#
#   Render.messages(messages, opts)
#   Render.labels(labels, opts)
#   ...
#
class Render
  constructor: () ->
    throw new Error('Cannot create Render object')

  #
  # Render an array of messages to the main pane
  #
  @messages: (messages) =>
    $content = $('.content')

    $content.fadeOut 200, () =>
      $content.html(JST['views/messages/index']({ messages:messages }))
      $content.fadeIn 200

      $('.left-pane .message').draggable
        addClasses: false
        appendTo: 'body'
        cursor: 'pointer'
        cursorAt:
          top: 15
          left: 0
        helper: ->
          $helper = $('<div class="btn" style="padding:1px 3px"><span class="icon icon-envelope"></span></div>')
          $copy = $(@).clone()
          return $helper

      $('.left-pane .message').droppable
        addClasses: false
        accept: '.sidebar-label'
        hoverClass: 'selected'
        drop: (e, ui) ->
          $message = $(e.target)
          $label = $(ui.draggable)

          label_ids = $.makeArray($message.find('.label')).map (l) -> $(l).attr('data-label-id')
          unless $label.attr('data-label-id') in label_ids
            $.post("#{$message.attr('href')}/toggle_label", { label_id:$label.attr('data-label-id') })

  # Render a single message
  @message: (message) =>
    JST['views/messages/_message']({ message:message })


  #
  # Render labels
  #
  labels: (labels) =>

# export to the global namespace
window.Render = Render
