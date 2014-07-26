/// <reference path="../../lib/_init.d.ts" />
  
var WHITESPACE_REGEX, ctx,
  __slice = [].slice;

WHITESPACE_REGEX = /\s+/g;

//if (Meteor.isClient) {
ctx = document.createElement('canvas').getContext('2d');
//} else {
//  ctx = new PDFJS.canvas(1000, 1000).getContext('2d');
//}

PDFJS.pdfTextSegment = function(textContent, textContentIndex, geom) {
  var angle, canvasWidth, fontAscent, fontHeight, segment, x, y;
  fontHeight = geom.fontSize * Math.abs(geom.vScale);
  fontAscent = geom.ascent ? geom.ascent * fontHeight : geom.descent ? (1 + geom.descent) * fontHeight : fontHeight;
  canvasWidth = geom.canvasWidth * Math.abs(geom.hScale);
  segment = {
    geom: geom,
    text: textContent[textContentIndex].str,
    direction: textContent[textContentIndex].dir,
    angle: geom.angle,
    textContentIndex: textContentIndex,
    width: 0,
    scale: 1
  };
  segment.isWhitespace = !/\S/.test(segment.text);
  segment.style = {
    fontSize: fontHeight,
    fontFamily: geom.fontFamily,
    left: geom.x + fontAscent * Math.sin(segment.angle),
    top: geom.y - fontAscent * Math.cos(segment.angle)
  };
  if (!segment.isWhitespace) {
    ctx.font = "" + segment.style.fontSize + "px " + segment.style.fontFamily;
    segment.width = ctx.measureText(segment.text).width;
    assert(segment.width >= 0, segment.width);
    if (segment.width) {
      angle = segment.angle * (180 / Math.PI);
      segment.scale = canvasWidth / segment.width;
      segment.style.transform = "rotate(" + angle + "deg) scale(" + segment.scale + ", 1)";
      segment.style.transformOrigin = '0% 0%';
    }
  }
  segment.boundingBox = {
    width: canvasWidth,
    height: fontHeight,
    left: segment.style.left,
    top: segment.style.top
  };
  if (segment.angle !== 0.0) {
    x = [segment.boundingBox.left, segment.boundingBox.left + segment.boundingBox.width * Math.cos(segment.angle), segment.boundingBox.left - segment.boundingBox.height * Math.sin(segment.angle), segment.boundingBox.left + segment.boundingBox.width * Math.cos(segment.angle) - segment.boundingBox.height * Math.sin(segment.angle)];
    y = [segment.boundingBox.top, segment.boundingBox.top + segment.boundingBox.width * Math.sin(segment.angle), segment.boundingBox.top + segment.boundingBox.height * Math.cos(segment.angle), segment.boundingBox.top + segment.boundingBox.width * Math.sin(segment.angle) + segment.boundingBox.height * Math.cos(segment.angle)];
    segment.boundingBox.left = _.min(x);
    segment.boundingBox.top = _.min(y);
    segment.boundingBox.width = _.max(x) - segment.boundingBox.left;
    segment.boundingBox.height = _.max(y) - segment.boundingBox.top;
  }
  return segment;
};

PDFJS.pdfImageSegment = function(geom) {
  return {
    geom: geom,
    boundingBox: _.pick(geom, 'left', 'top', 'width', 'height'),
    style: _.pick(geom, 'left', 'top', 'width', 'height')
  };
};

PDFJS.pdfExtractText = function() {
  var t, text, textContent, textContents, texts;
  textContents = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  texts = (function() {
    var _i, _len, _results;
    _results = [];
    for (_i = 0, _len = textContents.length; _i < _len; _i++) {
      textContent = textContents[_i];
      text = ((function() {
        var _j, _len1, _results1;
        _results1 = [];
        for (_j = 0, _len1 = textContent.length; _j < _len1; _j++) {
          t = textContent[_j];
          _results1.push(t.str);
        }
        return _results1;
      })()).join(' ');
      text = text.trim().replace(WHITESPACE_REGEX, ' ');
      _results.push(text);
    }
    return _results;
  })();
  return texts.join(' ');
};
