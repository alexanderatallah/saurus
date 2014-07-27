properEntities =
    NNP: true,
    NNPS: true

isEntity = (word) ->
    return properEntities[word[1]]?

getWikipediaTitle = (done) ->
    client.get '/w/api.php?action=opensearch&search=' + encodeURIComponent(wikipediaPartialTitle) + '&format=json', (err, res, body) ->
        if err
            done(err)
        else
            done(body[1][0])

getImageURL = (done) ->
    url = "/w/api.php?action=query&titles=" + encodeURIComponent(wikipediaPartialTitle) + "&prop=pageimages&format=json&pithumbsize=100"
    client.get url, (err, res, body) ->
        if err
            done(err)
        else
            firstKeyObj = body.query.pages[Object.keys(body.query.pages)[0]]
            if not firstKeyObj.thumbnail
                return done(null)
            ret = firstKeyObj.thumbnail.source;
            done(ret)


pos = Meteor.require('pos')
BASE_URL = 'http://en.wikipedia.org'
request = Meteor.require('request-json');
client = request.newClient(BASE_URL);
wikipediaPartialTitle = null;

Meteor.methods(
    getWikipediaEntity : (wordIndex, words) ->
        # wordIndex = 7
        # words = "I am driving to Mount Rushmore and Kansas State University very soon."

        # console.log words, wordIndex
        words = new pos.Lexer().lex(words.join(' ').replace("'", ''));
        taggedWords = new pos.Tagger().tag(words);
        for i in [0..wordIndex]
            word = words[i]
            if /[\.,-\/#!?$%\^&\*;:{}=\-_`~()]/g.test(word)
                wordIndex += 1

        # console.log wordIndex
        console.log taggedWords[wordIndex]
        if not isEntity(taggedWords[wordIndex])
            return false

        completeEntity = []
        for i in [Math.max(wordIndex - 5, 0).. Math.min(wordIndex + 5, taggedWords.length)] by 1
            word = taggedWords[i]
            if not word
                continue
            # console.log i
            # console.log word
            if isEntity(word)
                completeEntity.push(word[0])
            else
                if i < wordIndex
                    completeEntity = []
                else
                    break

        wikipediaPartialTitle = completeEntity.join ' '
        wikipediaFullTitle = Async.runSync(getWikipediaTitle).error
        ret = {
            title: wikipediaFullTitle
            url: BASE_URL + '/wiki/' + encodeURIComponent(wikipediaFullTitle)
            imageURL: Async.runSync(getImageURL).error
        }

        console.log ret

        return ret
)




# getCompleteEntity =

    # return taggedWords[wordIndex][1] == 'NNP'

# getCompleteEntity(4, "I am driving to Mount Rushmore and Kansas State University very soon.")
# .then((wikipediaEntry) ->
#     console.log wikipediaEntry
#     )
