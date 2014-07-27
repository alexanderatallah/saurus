Deps.autorun ->
  words = Session.get 'words'
  i = Session.get 'currWordIndex'
  if words
    new Synonyms(words.join(' ')).find(i)

Template.synonyms.hasNoEntry = ->
  syns = Session.get('synonyms')
  not syns or syns.length == 0

Template.synonyms.entries = ->
  Session.get 'synonyms'