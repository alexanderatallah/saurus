Template.wikipedia.wikipediaTitle =->
    wordIndex = Session.get('currWordIndex')
    words = Session.get('words')
    test = Meteor.call('getWikipediaEntity', wordIndex, words, (error, result) ->
        return Session.set('wikipediaEntry', result)
    )
    if Session.get('wikipediaEntry')
        return Session.get('wikipediaEntry').url
    return ''


Template.wikipedia.wikipediaURL =->
    if Session.get('wikipediaEntry')
        return Session.get('wikipediaEntry').title
    return ''
