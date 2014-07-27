Template.wikipedia.wikipediaTitle = ->
    wordIndex = Session.get('currWordIndex')
    words = Session.get('words')
    if wordIndex && words
        Meteor.call('getWikipediaEntity', wordIndex, words, (error, result) ->
            return Session.set('wikipediaEntry', result)
        )
    if Session.get('wikipediaEntry')
        return Session.get('wikipediaEntry').title
    return ''


Template.wikipedia.wikipediaURL = ->
    if Session.get('wikipediaEntry')
        return Session.get('wikipediaEntry').url
    return ''

Template.wikipedia.wikipediaImageURL = ->
    if Session.get('wikipediaEntry')
        return Session.get('wikipediaEntry').imageURL
    return ''

Template.wikipedia.wikipediaText = ->
    if !Session.get('wikipediaEntry')
        return ''

    if Session.get('wikipediaText')
        return Session.get('wikipediaText')

    url = "http://en.wikipedia.org/w/api.php?action=parse&page=" + encodeURIComponent(Session.get('wikipediaEntry').title)  + "&prop=text&section=0&format=json&callback=?"

    $.getJSON url, (data) ->
      for text of data.parse.text
        text = data.parse.text[text].split("<p>")
        pText = ""
        for p of text

          #Remove html comment
          text[p] = text[p].split("<!--")
          if text[p].length > 1
            text[p][0] = text[p][0].split(/\r\n|\r|\n/)
            text[p][0] = text[p][0][0]
            text[p][0] += "</p> "
          text[p] = text[p][0]

          #Construct a string from paragraphs
          if text[p].indexOf("</p>") is text[p].length - 5
            htmlStrip = text[p].replace(/<(?:.|\n)*?>/g, "") #Remove HTML
            splitNewline = htmlStrip.split(/\r\n|\r|\n/) #Split on newlines
            for newline of splitNewline
              unless splitNewline[newline].substring(0, 11) is "Cite error:"
                pText += splitNewline[newline]
                pText += "\n"
        pText = pText.substring(0, pText.length - 2) #Remove extra newline
        pText = pText.replace(/\[\d+\]/g, "") #Remove reference tags (e.x. [1], [4], etc)
        console.log pText
        Session.set('wikipediaText', pText)
        return pText
    return ''
