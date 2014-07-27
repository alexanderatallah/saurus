Package.describe({
  summary: "REPLACEME - What does this package (or the original one you're wrapping) do?"
});

Npm.depends({
  // 'xml2json': '0.4.0'
  'natural': '0.1.28',
  'WNdb': '3.1.1'
});

Package.on_use(function (api, where) {
  // api.use(['underscore', 'check'], ['client', 'server']);
  api.add_files(['alchemyapi.js', 'server_methods.js'], 'server');
  api.export('AlchemyAPI', 'server');

  api.add_files('synonyms.js', ['client', 'server']);
  api.export('Synonyms', ['client', 'server']);
});

Package.on_test(function (api) {
  api.use('synonyms');

  api.add_files('synonyms_tests.js', ['client', 'server']);
});
