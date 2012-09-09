class Envelope.Helpers.Forms
  @bootstrap_field: (options) ->
    options.type ||= 'text'
    options.id ||= options.name.toLowerCase().replace /\./g, '_'

    optionsString = _.map(options, (v,k) -> "#{k}=\"#{v}\"").join(' ')

    "<div class=\"control-group\">
      <label class=\"control-label\">#{options.label}</label>
      <div class=\"controls\">
        <input #{optionsString}>
      </div>
    </div>"

  @bootstrap_select: (options) ->
    options.id ||= options.name.toLowerCase().replace /\./g, '_'

    selectOptionsString = _.compact(_.map(options, (v,k) -> "#{k}=\"#{v}\"" unless k in ['options', 'value'])).join(' ')
    placeholderString = "<option>#{options.placeholder}</option>" if options.placeholder?
    optionsString = _.map(options.options, (option) -> "<option #{_.map(option, (v,k) -> "#{k}=\"#{v}\"").join(' ')}>#{option.label || option.value}</option>").join('')

    "<div class=\"control-group\">
      <label class=\"control-label\">#{options.label}</label>
      <div class=\"controls\">
        <select #{selectOptionsString}>
          #{placeholderString}
          #{optionsString}
        </select>
      </div>
    </div>"
