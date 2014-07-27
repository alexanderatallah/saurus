Session.set("text", "")
Session.set("selectedWord", "")

lastCode = -1

Template.editor.events({
  'keydown .text-input': (e) =>
    if e.keyCode is 40 or e.keyCode is 38
      trySynonymUpdate(e, e.keyCode is 40)
    if e.keyCode is 13
      trySynonymEnter(e)
  'keyup .text-input': (e) =>
    updateText()
  'click .text-input': (e) =>
    updateText()
})

trySynonymEnter = (e, loc) =>
  console.log "return pressed"
  e.preventDefault()
  syns = Session.get('synonyms')
  curr = -1
  for i in [0..(syns.length-1)]
    curr = i if syns[i]?.selected
  console.log curr
  return if curr is -1

  currWord = Session.get('words')[Session.get('currWordIndex')]
  loc = window.getSelection().getRangeAt(0).startOffset
  loc -= currWord.length
  text = $('.text-input').text()
  text = text.replace(currWord, syns[curr].syn)
  loc += syns[curr].syn.length
  $('.text-input').text(text)

  el = $('.text-input').get(0)
  range = document.createRange()
  sel = window.getSelection()
  range.setStart(el.childNodes[0], loc)
  sel.removeAllRanges()
  sel.addRange(range)

  updateText()


trySynonymUpdate = (e, down) =>
  syns = Session.get('synonyms')
  return unless syns
  return unless syns.length >= 1
  e.preventDefault()
  console.log "syns", syns
  curr = -1
  for i in [0..(syns.length-1)]
    console.log syns[i]
    curr = i if syns[i]?.selected
  console.log "curr", curr
  next = curr + (if down then 1 else -1)
  next = syns.length - 1 if next is -2
  console.log 'next', next
  next = -1 if next is syns.length
  syns[curr].selected = false unless curr is -1
  syns[next].selected = true unless next is -1
  Session.set('synonyms', syns)

updateText = =>
  text = $('.text-input').text() 
  Session.set('text', text)
  loc = window.getSelection().getRangeAt(0).startOffset
  console.log 'loc_test', loc
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
    return new Handlebars.SafeString(text.replace(/\s/g, '</span> <span>').replace(new RegExp('<span></span>', 'g'), ''))
})