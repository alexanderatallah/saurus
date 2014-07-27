properEntities =
    NNP: true,
    NNPS: true

isEntity = (word) ->
    return properEntities[word[1]]?

getWikipediaLink = (done) ->
    client.get '/w/api.php?action=opensearch&search=' + encodeURIComponent(wikipediaTitle) + '&format=json', (err, res, body) ->
        if err
            done(err)
        else
            done(BASE_URL + '/wiki/' + encodeURIComponent(body[1][0]))

pos = Meteor.require('pos')
request = Meteor.require('request-json');
BASE_URL = 'http://en.wikipedia.org'
client = request.newClient(BASE_URL);
wikipediaTitle = null;

Meteor.methods(
    getWikipediaEntity : (wordIndex, words) ->
        # return 'hi'
        wordIndex = 7
        words = "I am driving to Mount Rushmore and Kansas State University very soon."
        words = new pos.Lexer().lex(words);
        taggedWords = new pos.Tagger().tag(words);

        if not isEntity(taggedWords[wordIndex])
            return false

        completeEntity = []
        for i in [Math.max(wordIndex - 5, 0).. Math.min(wordIndex + 5, taggedWords.length)] by 1
            word = taggedWords[i]
            if isEntity(word)
                completeEntity.push(word[0])
            else
                if i < wordIndex
                    completeEntity = []
                else
                    break
        wikipediaTitle = completeEntity.join ' '
        ret = {
            title: wikipediaTitle
            url: Async.runSync(getWikipediaLink).error
        }
        return ret
        # return getWikipediaLinkSync(wikipediaTitle);
            # return [
            #     wikipediaTitle,
            #     url
            # ]
)




# getCompleteEntity =

    # return taggedWords[wordIndex][1] == 'NNP'

# getCompleteEntity(4, "I am driving to Mount Rushmore and Kansas State University very soon.")
# .then((wikipediaEntry) ->
#     console.log wikipediaEntry
#     )
