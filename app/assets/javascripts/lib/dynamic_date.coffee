#
# Seth Vargo
#
# Takes in a time object (in seconds) and returns a pretty formatted date
#

class DynamicDate
  @format = (date) ->
    MINUTE_AGO = 60
    HOUR_AGO = 3600
    DAY_AGO = 86400
    YEAR_AGO = 31557600

    date = new Date(Date.parse(date))
    diff = ((new Date()).getTime() - date.getTime()) / 1000

    return if isNaN(diff)

    return diff < 1*MINUTE_AGO && 'just now' ||
           diff < 2*MINUTE_AGO && 'a minute ago' ||
           diff < 1*HOUR_AGO && Math.floor( diff / 60 ) + ' minutes ago' ||
           diff < 1*DAY_AGO && date.format('h:MMtt') ||
           diff < 2*DAY_AGO && 'Yesterday' ||
           diff < 1*YEAR_AGO && date.format('mmm d') ||
           diff > 1*YEAR_AGO && date.format('m/d/yyyy')

window.DynamicDate = DynamicDate