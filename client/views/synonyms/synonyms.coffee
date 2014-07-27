Deps.autorun ->
  words = Session.get 'words'
  i = Session.get 'currWordIndex'
  if words
    new Synonyms(words.join(' ')).find(i)

Template.synonyms.hasNoEntry = ->
  syns = Session.get('synonyms')
  not syns or syns.length == 0

Template.synonyms.entries = ->
  Session.get('synonyms')?.slice(0, 10)

Template.synonyms.hasGloss = (obj) =>
  return obj.gloss?.length > 4

Template.synonyms.formatGloss = (gloss) =>
  return gloss if gloss.length < 35
  return gloss.substring(0, 32) + '...'
