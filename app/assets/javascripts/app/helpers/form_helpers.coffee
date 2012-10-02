class Envelope.FormHelpers
  @bootstrap_field: (options) ->
    options.type ||= 'text'
    options.id ||= options.name.toLowerCase().replace /\./g, '_'

    optionsString = ("#{k}=\"#{v}\"" for k,v of options).join(' ')

    "<div class=\"control-group\">
      <label class=\"control-label\">#{options.label}</label>
      <div class=\"controls\">
        <input #{optionsString}>
      </div>
    </div>"
