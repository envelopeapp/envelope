class Envelope.Collections.CommonAccountSettings extends Backbone.Collection
  url: '/api/common_account_settings'

  comparator: (common_account_setting) ->
    common_account_setting.get('name')
