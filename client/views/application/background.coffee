@ImageGenerator = ->
  
  ###
  Flickr URL that will give us lots and lots of whatever we're looking for.
  
  See http://www.flickr.com/services/api/flickr.photos.search.html for
  details about the construction of this URL.
  ###
  @searchOnFlickr_ = ->
    "https://secure.flickr.com/services/rest/?" + "method=flickr.photos.search&" + "api_key=8affb9daefb7122675eeaf8cf9c2ef36&" + "text=" + encodeURIComponent(@query) + "&" + "safe_search=1&" + "content_type=6&" + "sort=relevance&" + "per_page=3"
  
  ###
  Sends an XHR GET request to grab photos of lots and lots of images. The
  XHR's 'onload' event is hooks up to the 'showPhoto_' method.
  ###
  @requestImage = (query) ->
    @query = query
    req = new XMLHttpRequest()
    req.open "GET", @searchOnFlickr_(), true
    req.onload = @showPhoto_.bind(this)
    req.send null

  
  ###
  Handle the 'onload' event of our kitten XHR request, generated in
  'requestImage', by generating 'img' elements, and stuffing them into
  the document for display.
  ###
  @showPhoto_ = (e) ->
    images = e.target.responseXML.querySelectorAll("photo")
    image = images[0]
    return unless image

    $("body").css
      'background-image': 'url(' + @constructImageURL_(image) + ')'
      'background-size': 'cover'

    # while i < images.length
    # img = document.createElement("img")
    # img.src = @constructImageURL_(images[i])
    # img.setAttribute "alt", images[i].getAttribute("title")
    # document.body.appendChild img
      # i++

  @reset = ->
    $("body").css
      'background-image': ''

  ###
  Given a photo, construct a URL using the method outlined at
  http://www.flickr.com/services/api/misc.urlKittenl
  ###
  @constructImageURL_ = (photo) ->
    "http://farm" + photo.getAttribute("farm") + ".static.flickr.com/" + photo.getAttribute("server") + "/" + photo.getAttribute("id") + "_" + photo.getAttribute("secret") + ".jpg"

  @

Deps.autorun ->
  bg = new ImageGenerator()
  topics = Session.get('topics')
  if topics && topics.length
    bg.requestImage(topics[0])
  else
    bg.reset()
