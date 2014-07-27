throttled = _.throttle ((words) =>
  new Semantics(words.join(' ')).topics() if words), 10000

Deps.autorun =>
  words = Session.get 'words'
  throttled(words)

  # return if @last_run? and Date.now() - @last_run < 10000
  # @last_run = Date.now()

