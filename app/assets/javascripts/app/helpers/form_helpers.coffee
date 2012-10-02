_.mixin
  bootstrap_field: (options) ->
    options.type ||= 'text'
    options.id ||= options.name.toLowerCase().replace /\./g, '_'

    options.list = _.compact(("#{k}=\"#{_.escape(v)}\"" unless k in ['label']) for k,v of options)

    result = new String _.template('
    <div class="control-group">
      <% if(options.label) { %>
        <label class="control-label"><%- options.label %></label>
      <% } %>

      <div class="controls">
        <input <%= options.list.join(" ") %>>
      </div>
    </div>
    ')(options: options)
    result.ecoSafe = true
    result

  bootstrap_select: (xoptions) ->
    console.log xoptions.options
    options.id ||= options.name.toLowerCase().replace /\./g, '_'

    options.select_options = _.compact(_.map(options, (v,k) -> "#{_.escape(k)}=\"#{_.escape(v)}\"" unless k in ['options', 'value']))
    options.options.unshift "<option>#{options.placeholder}</option>" if options.placeholder?
    options.options = _.map(options.options, (option) -> "<option #{_.map(option, (v,k) -> "#{_.escape(k)}=\"#{_.escape(v)}\"").join(' ')}>#{option.label || option.value}</option>")

    result = new String _.template('
      <div class="control-label">
        <% if(options.label) { %>
        <label class="control-label"><%- options.label %></label>
        <% } %>

        <div class="controls">
          <select <%= options.select_options %>>
            <%= options.options.join("") %>
            <% for(var option in options.options) { %>
              <%= option %>
            <% } %>
          </select>
        </div>
      </div>
    ')(options: options)
    result.ecoSafe = true
    result
