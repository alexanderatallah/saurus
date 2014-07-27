throttledMeteorCall = _.throttle(Meteor.call, 2000)

Template.wikipedia.wikipediaTitle = ->
    wordIndex = Session.get('currWordIndex')
    words = Session.get('words')
    # console.log words
    if wordIndex != null && words
         throttledMeteorCall 'getWikipediaEntity', wordIndex, words, (error, result) ->
            if not error
                Session.set('wikipediaEntry', result)
            else
                Session.set('wikipediaEntry', null)

    wikipediaEntry = Session.get('wikipediaEntry')
    return wikipediaEntry.title if wikipediaEntry
    return ''

Template.wikipedia.hasNoEntry = ->
    wikipediaEntry = Session.get('wikipediaEntry')
    if wikipediaEntry and wikipediaEntry != false
        return false
    return true

Template.wikipedia.hasNoText = ->
    text = Session.get('wikipediaText')
    return false if text and text != false
    return true

Template.wikipedia.wikipediaURL = ->
    wikipediaEntry = Session.get('wikipediaEntry')
    if wikipediaEntry
        return wikipediaEntry.url
    return ''

Template.wikipedia.wikipediaImageURL = ->
    wikipediaEntry = Session.get('wikipediaEntry')
    if wikipediaEntry
        return wikipediaEntry.imageURL
    return ''

Template.wikipedia.wikipediaText = ->
    wikipediaEntry = Session.get('wikipediaEntry')
    if !wikipediaEntry
        return ''

    url = "http://en.wikipedia.org/w/api.php?action=parse&page=" + encodeURIComponent(wikipediaEntry.title)  + "&prop=text&section=0&format=json&callback=?"

    $.getJSON url, (data) ->
      for text of data.parse.text
        text = data.parse.text[text].split("<p>")
        pText = ""
        for p of text

          text[p] = text[p].split("<!--")
          if text[p].length > 1
            text[p][0] = text[p][0].split(/\r\n|\r|\n/)
            text[p][0] = text[p][0][0]
            text[p][0] += "</p> "
          text[p] = text[p][0]

          if text[p].indexOf("</p>") is text[p].length - 5
            htmlStrip = text[p].replace(/<(?:.|\n)*?>/g, "")
            splitNewline = htmlStrip.split(/\r\n|\r|\n/)
            for newline of splitNewline
              unless splitNewline[newline].substring(0, 11) is "Cite error:"
                pText += splitNewline[newline]
                pText += "\n"
        pText = pText.substring(0, pText.length - 2)
        pText = pText.replace(/\[\d+\]/g, "")
        Session.set('wikipediaText', pText)
        return pText
    wikipediaText = Session.get('wikipediaText')
    if wikipediaText
        return wikipediaText.substring(0, 150) + '...'
    return ''

