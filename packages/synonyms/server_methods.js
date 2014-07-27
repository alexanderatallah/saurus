var future = Npm.require('fibers/future');
var http = Npm.require('http');
var alchemy = new AlchemyAPI();
var natural = Npm.require('natural');
var wordnet = new natural.WordNet();
// var WEBSTER_API_KEY = "eee644f9-33cd-496e-a65b-73cf8376ca0f";

Meteor.methods({
  'synonyms': function(word, contextWords) {
    var fut = new future();

    wordnet.lookup(word, function(results) {
      // results.forEach(function(result) {
      //   console.log('------------------------------------');
      //   console.log(result.lemma);
      //   console.log(result.pos);
      //   console.log(result.synonyms);
      //   console.log(result.gloss);
      // });
      var formatted = scoreSynonyms(results, contextWords);
      console.log(formatted);
      fut.return(formatted);
    });

    return fut.wait();
  },
  'entities': function(words, index) {
    var fut = new future();
    alchemy.entities("text", words, {showSourceText: 1}, function(response) {
      console.log(response);
      fut.return(response);
    });
    return fut.wait();
  },
  'concepts': function(words, index) {
    var fut = new future();
    alchemy.concepts("text", words, {showSourceText: 1}, function(response) {
      console.log(response);
      fut.return(response);
    });
    return fut.wait();
  }
});

// return best synonyms as [synonym, gloss]
function scoreSynonyms(senses, contextWords) {
  var scores = {};
  var glosses = {};

  _.each(senses, function(sense, i) {
    var score = _.intersection(contextWords, sense.gloss.split(/\s+/)).length;
    glosses[sense.lemma] = sense.gloss;
    _.each(sense.synonyms, function(syn) {
      if (!scores[syn]) scores[syn] = 0;
      scores[syn] += score;
    });
  });

  return _.chain(scores).keys()
    .sortBy(function(syn) {
      return -1 * scores[syn];
    })
    .map(function(syn) {
      return {
        syn: syn,
        gloss: glosses[syn] || null,
        score: scores[syn]
      };
    })
    .value();
}

  // 'synonymsWebster': function(word) {
  //   var fut = new future();
  //   var url = "http://www.dictionaryapi.com/api/v1/references/thesaurus/xml/" + word + "?key=" + WEBSTER_API_KEY;

  //   http.get(url, function(res) {
  //     var response = "";
  //     res.setEncoding('utf8');
  //     res.on('data', function(chunk) {
  //       response += chunk;
  //     }).on('end', function() {
  //       var jsonRes = xml2json.toJson(response);
  //       fut.return(jsonRes["entry_list"]["entry"][0]);
  //     });
  //   }).on('error', function(e) {
  //     console.log(e);
  //     fut.throw(e.message);
  //   });
    
  //   return fut.wait();
  // }
