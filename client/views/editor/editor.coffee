Session.set("text", "")
Session.set("selectedWord", "")

Template.editor.events({
  'keyup .text-input': (e) =>
    updateText()
  'click .text-input': (e) =>
    updateText()
})

updateText = =>
  text = $('.text-input').text() 
  Session.set('text', text)
  loc = window.getSelection().getRangeAt(0).startOffset
  letters = text.split('')
  words = text.split(/\s+/)
  arr = letters.slice(0)
  j = 0
  lastItem = ''
  charWordsMap = _.map(arr, (item) =>
    j = j + 1 if lastItem is ' ' and item != ' '
    lastItem = item
    return j
  )
  charWordsMap.push(charWordsMap[charWordsMap.length - 1])
  currWordIndex = charWordsMap[loc]
  Session.set('words', words)
  Session.set('currWordIndex', currWordIndex)
  i = loc
  while i > 0 and letters[i - 1] isnt ' '
    i = i - 1 
  Session.set('indexIntoCurrWord', loc - i)

Template.editor.helpers({
  computedOutputText: =>
    text = "<span>" + Session.get('text') + "</span>"
    return new Handlebars.SafeString(text.replace(/\s/g, '</span>&nbsp;<span>').replace(new RegExp('<span></span>', 'g'), ''))
})