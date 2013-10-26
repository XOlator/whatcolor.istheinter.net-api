window.mousetimeout = null;

(function($) {
  $(document).ready(function() {
    start_mouse_timeout();
    $('html,body').on('mousemove', function() {
      $('body').removeClass('sleep')
      clearTimeout(window.mousetimeout);
      start_mouse_timeout();
    })
  });
})(jQuery);

function start_mouse_timeout() {
  window.mousetimeout = setTimeout(function() {
    $('body').addClass('sleep');
  }, 5000);
}

function number_to_delimiter(i) {
  var parts = (i+'').split('.')
  parts[0] = parts[0].replace(/(\d)(?=(\d\d\d)+(?!\d))/, "$1,")
  return parts.join('.')
}


var Color = {};

Color.Current = {
  data : {},
  _fetching : false,
  _refresh : 60000,
  _interval : null,

  start : function() {
    var t = this;
    this.load();
    this._interval = setInterval(function() {t.fetch();}, this._refresh);
  },

  load : function() {
    jQuery('body').css('background-color', '#'+ this.data.pixel.hex);
    jQuery('#pixel_hex_result').html('#'+ this.data.pixel.hex).siblings('.box').css('background-color', '#'+ this.data.pixel.hex);
    jQuery('#dominant_hex_result').html('#'+ this.data.dominant.hex).siblings('.box').css('background-color', '#'+ this.data.dominant.hex);;
    jQuery('#color_result_count').html( number_to_delimiter(this.data.count) );
    jQuery('#color_result_time').attr('datatime', this.data.cached_at).html( moment(this.data.cached_at).format('MMM D, YYYY h:mm:ssa') );
  },

  fetch : function() {
    var t = this;
    if (t._fetching) return false;
    t._fetching = true;
    jQuery.ajax('/api/current.json', {dataType: 'json',
      success: function(d,s,e){
        t.data = d;
        t._fetching = false;
        t.load();
      }
    });
  }
};

Color.Stream = {
  data : [],
  _index : 0,
  _timeout : null,
  _speed : 2500,
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
    jQuery('#pixel_hex_result').html('#'+ o.pixel.hex).siblings('.box').css('background-color', '#'+ o.pixel.hex);
    jQuery('#dominant_hex_result').html('#'+ o.dominant.hex).siblings('.box').css('background-color', '#'+ o.dominant.hex);;
    jQuery('#color_web_page_url').html(o.page.url);

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
