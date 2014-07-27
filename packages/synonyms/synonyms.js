/*
 * SYNONYMS
 * Client and server side
 * 
 */
Synonyms = function (text) {
  var self = this;
  self.words = text.split(/\s+/);

  self.find = function (index) {
    Meteor.call('synonyms', self.words[index], self.words, function(err, res) {
      Session.set('synonyms', res);
    });
  }

  self.concepts = function () {
    var concepts = Meteor.call('concepts', self.words);
    return concepts;
  }
    
  return self;
}
