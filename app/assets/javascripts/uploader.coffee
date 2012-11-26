class Uploader
  @text = '<p>Drag and drop files here or <a href="#" id="browse-button">browse</a>!</p>'

  constructor: (drop_zone, file_field) ->
    @attachments = []
    @clones = []

    @$file_field = $(file_field)
    @$file_field.bind 'change', @manual
    $('#browse-button').live 'click', =>
      @$file_field.click()

    @$drop_zone = $(drop_zone)
    @$drop_zone.bind 'dragenter', @noop
    @$drop_zone.bind 'dragexit', @noop
    @$drop_zone.bind 'dragover', @noop
    @$drop_zone.bind 'drop', @drop

    @render()

  # Perform a noop by preventing the default behavior and stopping
  # event propagation.
  noop: (e) ->
    # e.stopPropagation()
    e.preventDefault()

  # Handler for when a file is dropped.
  drop: (e) =>
    @noop e

    clone = @$file_field.clone()
    clone.prop 'files', e.dataTransfer.files
    @clones.push clone

    @render()

  # Handle a manual file upload (using the HTML element)
  manual: (e) =>
    @noop e

    for file in e.currentTarget.files
      @attachments.push file

    @render()

  # Render helper function that redraws the HTML element
  render: =>
    html = []

    for clone,i  in @clones
      html.push clone.wrap('<span></span>').parent().html()

      for file, j in clone.prop 'files'
        html.push '<button class="btn btn-mini">'
        html.push file.name
        html.push '</button>'

    html.push Uploader.text

    @$drop_zone.html html.join('')

@Uploader = Uploader
