/*
 * SYNONYMS
 * Client and server side
 * 
 */
Synonyms = function (text) {
  var self = this;
  self.text = text;
  self.words = text.split(/\s+/);

  self.find = function (index) {
    var word = self.words[index];
    // remove punctuation from word
    word = word.replace(/[\.,-\/#!$%\^&\*;:{}=\-_`~()]/g,"");

    Meteor.call('synonyms', word, self.words, function(err, res) {
      res = res.slice(0, 10)
      Session.set('synonyms', res);
    });
  }

  self.concepts = function () {
    var concepts = Meteor.call('concepts', self.text);
    return concepts;
  }
    
  return self;
}

Semantics = function (text) {
  var self = this;
  self.text = text;

  self.topics = function() {
    Meteor.call('taxonomy', self.text, function(err, res) {
      Session.set('topics', res);
    });
  }

  return self;
}