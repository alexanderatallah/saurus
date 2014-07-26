/// <reference path="../../../lib/_init.d.ts" />

Template['editor'].events({
  
  'keyup #main-text': function (e) {
    var $el = $(e.target);
    var fullText : string = $el.val();
    
    var state = Apollo.State['mainText'] = new Parser.State(fullText); //.update(Apollo.State['mainText']);
    
    if (state.doesEndClause()) {
      Meteor.call("parse", fullText, parseHandler);
    }
    
    var prefix = state.lastWord;
    if (prefix.length >= 2) {
      Session.set('entityQuery', prefix);
    } else {
      Session.set('entityQuery', null);
    }
    return true;
  }
});

Template['editor']['semanticOverlay'] = function() {
  
  var text = Session.get('mainTextValue');
  return text;
}

/**
 * HELPERS
 * 
 */

var parseHandler = function(err, res: ParserResult) {
  console.log(res);
  Session.set('mainTextValue', res.original);
}