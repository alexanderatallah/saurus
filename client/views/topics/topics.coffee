Deps.autorun ->
  words = Session.get 'words'
  updateTopics(words) if words

updateTopics = _.throttle (words) ->
  new Semantics(words.join(' ')).topics()
, 10000