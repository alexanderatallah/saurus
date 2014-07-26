/// <reference path="../lib/_init.d.ts" />

Meteor.publish('documents', function(options) {
  return Apollo.Documents.find({}, options);
});

Meteor.publish('singleDocument', function(id) {
  return id && Apollo.Documents.find(id);
});
