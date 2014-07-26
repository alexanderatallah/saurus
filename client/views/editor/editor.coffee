Template.editor.events = =>
  'keyup #main-text': (e) =>
    $el = $(e.target)
    fullText = $el.val()

Template.editor.semanticOverlay = =>
  text = Session.get('mainTextValue')
  return text

parseHandler = (err, res) =>
  console.log(res)
  Session.set('mainTextValue', res.original)
