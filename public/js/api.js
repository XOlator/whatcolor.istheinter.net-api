var Color = {};


Color.Stream = {
  data : [],
  _index : 0,
  _timeout : null,
  _speed : 1000,
  _prefetch : 3,
  _playing : false,
  _fetching : false,

  start : function() {
    this._playing = true;
    this.load();
    return true;
  },
  stop : function() {
    clearTimeout(this._timeout);
    this._playing = false;
    return false;
  },

  load : function() {
    var t = this, o = t.data[t._index];
    if (!o) return t.stop();

    jQuery('body').css('background-color', '#'+ o.pixel.hex);
    jQuery('#pixel_hex_result').html('#'+ o.pixel.hex);
    jQuery('#dominant_hex_result').html('#'+ o.dominant.hex);
    jQuery('#color_web_page_url').html('#'+ o.page.url);

    if (t._index+1+t._prefetch > t.data.length) t.fetch();

    t._timeout = setTimeout(function() {
      t._index++;
      t.load();
    }, t._speed);
  },

  fetch : function() {
    var t = this;
    if (t._fetching) return false;
    t._fetching = true;
    jQuery.ajax('/api/stream.json', {dataType: 'json',
      success: function(d,s,e){
        t.data = t.data.slice(t._index).concat(d);
        t._index = 0;
        t._fetching = false;
        if (!t._playing) t.start();
      }
    });
  }
};
