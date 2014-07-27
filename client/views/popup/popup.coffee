Template.popup.helpers({
  top: =>
    index = Session.get('currWordIndex') ? 0
    spans = $('.text-output > span')
    return 0 if index >= spans.size()
    top = spans.eq(index).offset().top - 15
    console.log 'top', top
    return top

  left: =>
    index = Session.get('currWordIndex') ? 0
    spans = $('.text-output > span')
    return 0 if index >= spans.size()
    left = spans.eq(index).offset().left
    console.log 'left', left
    return left
})