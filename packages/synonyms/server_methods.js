var future = Npm.require('fibers/future');
var http = Npm.require('http');
var alchemy = new AlchemyAPI();
var natural = Npm.require('natural');
var wordnet = new natural.WordNet();
// var WEBSTER_API_KEY = "eee644f9-33cd-496e-a65b-73cf8376ca0f";

Meteor.methods({
  'synonyms': function(word, contextWords) {
    check(word, String);
    check(contextWords, Array);
    
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
      // console.log(formatted);
      fut.return(formatted);
    });

    return fut.wait();
  },
  'entities': function(context) {
    var fut = new future();
    alchemy.entities("text", context, {showSourceText: 1}, function(response) {
      console.log(response);
      fut.return(response);
    });
    return fut.wait();
  },
  'concepts': function(context) {
    var fut = new future();
    alchemy.concepts("text", context, {showSourceText: 1}, function(response) {
      console.log(response);
      fut.return(response);
    });
    return fut.wait();
  },
  'taxonomy': function(context) {
    var fut = new future();
    alchemy.taxonomy("text", context, {showSourceText: 1}, function(response) {
      // console.log(response);
      var topics = getTopics(response.taxonomy);
      // console.log(topics);
      fut.return(topics);
    });
    return fut.wait();
  }
});

function getTopics(taxonomy) {
  return _.chain(taxonomy)
    .map(function(tax) {
      return tax.label.split('/')[1].split(' ')[0];
    })
    .uniq().value();
}

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
      syn = syn.replace(/[_]/g," ")
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
