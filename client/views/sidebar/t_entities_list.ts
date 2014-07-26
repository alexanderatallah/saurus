/// <reference path="../../../lib/_init.d.ts" />

Template['entitiesList']['entities'] = (): Entities.DAO[] => {
  var query = Session.get('entityQuery');
  if (query) {
    var q = { $regex: '^' + query, $options: 'i' }
    return Apollo.Entities.find({
        $or: [
          { name: q },
          { aliases: q },
        ]
      }, {
        limit: 10
      }).fetch();
  } else {
     return [];
  }
};
