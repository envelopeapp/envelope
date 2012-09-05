class Envelope.Helpers.Forms
  @bootstrap_field: (options) ->
    options.type ||= 'text'
    options.id ||= options.name.toLowerCase().replace /\./g, '_'

    optionsString = _.map(Object.keys(options), (k) -> "#{k}=\"#{options[k]}\"").join(' ')

    "<div class=\"control-group\">
      <label class=\"control-label\">#{options.label}</label>
      <div class=\"controls\">
        <input #{optionsString}>
      </div>
    </div>"
