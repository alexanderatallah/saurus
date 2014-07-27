ignoredNouns =
    'arent' : true, 'cant' : true, 'couldnt' : true, 'didnt' : true, 'doesnt' : true, 'dont' : true, 'hadnt' : true, 'hasnt' : true, 'havent' : true, 'hed' : true, 'hell' : true, 'hes' : true, 'Id' : true, 'Ill' : true, 'Im' : true, 'Ive' : true, 'isnt' : true, 'its' : true, 'lets' : true, 'mightnt' : true, 'mustnt' : true, 'shant' : true, 'shed' : true, 'shell' : true, 'shes' : true, 'shouldnt' : true, 'thats' : true, 'theres' : true, 'theyd' : true, 'theyll' : true, 'theyre' : true, 'theyve' : true, 'wed' : true, 'were' : true, 'weve' : true, 'werent' : true, 'whatll' : true, 'whatre' : true, 'whats' : true, 'whatve' : true, 'wheres' : true, 'whod' : true, 'wholl' : true, 'whore' : true, 'whos' : true, 'whove' : true, 'wont' : true, 'wouldnt' : true, 'youd' : true, 'youll' : true, 'youre' : true, 'youve' : true

properNounEntities =
    NNP: true
    NNPS: true

nounEntities =
    NN: true
    NNS: true

PROPER_NOUN_ENTITY = 'PROPER_NOUN_ENTITY'
NOUN_ENTITY = 'NOUN_ENTITY'

getEntityType = (word) ->
    if ignoredNouns[word[0]]?
        return null
    if properNounEntities[word[1]]?
        return PROPER_NOUN_ENTITY
    if nounEntities[word[1]]? && wordIsCapitalized(word[0])
        return NOUN_ENTITY
    return null;

wordIsCapitalized = (word) ->
    return capitalizeFirstLetter(word) == word

capitalizeFirstLetter = (word) ->
    return word.charAt(0).toUpperCase() + word.slice(1);

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
        # console.log words, wordIndex

        words = words.join(' ').replace(/'/g, '')
        words = new pos.Lexer().lex(words);

        taggedWords = new pos.Tagger().tag(words);
        for i in [0..wordIndex]
            word = words[i]
            if /[\.,-\/#!?$%\^&\*;:{}=\-_`~]/g.test(word)
                wordIndex += 1

        # console.log wordIndex

        console.log taggedWords[wordIndex]
        if not getEntityType(taggedWords[wordIndex])
            return false

        completeEntity = []
        lastEntityType = null;
        for i in [Math.max(wordIndex - 5, 0).. Math.min(wordIndex + 5, taggedWords.length)] by 1
            word = taggedWords[i]
            if not word
                continue
            # console.log i
            # console.log word
            entityType = getEntityType(word)
            if entityType and (entityType == lastEntityType or lastEntityType == null)
                completeEntity.push(word[0])
            else if entityType
                if i > wordIndex
                    break
                completeEntity = [word[0]]
            else
                if i < wordIndex
                    completeEntity = []
                else
                    break
            lastEntityType = entityType

        wikipediaPartialTitle = completeEntity.join ' '
        console.log wikipediaPartialTitle
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
