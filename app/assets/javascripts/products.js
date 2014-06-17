// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

//= require slider

$.act({
  "switch-tab[click]" : function (el, ev) {
    var nodes = el.parent().children();
    nodes.removeClass('active');
    el.addClass('active');
    var offset = el.prevAll().length;

    var tab = el.parent().parent().parent().find('.tab-containers:first').children().eq(offset);
    if (tab[0]) {
      tab.parent().children().removeClass('active');
      tab.addClass('active');
    }
  },
  "model-track[mouseover]" : function (el, ev) {
    if (!el.hasClass('tracked')) {
      el.addClass('tracked');

      el.bind('mousemove', function (ev) {
        var pos = ev.pageX - el.offset().left;
        var posPercentage = 1.0 * pos / el.width();
        
        var images = el.find('.model-source img')
        var imagePos = Math.min(images.length-1, Math.round(1.0 * posPercentage * images.length));
        el.children('img').attr('src', images.eq(imagePos).attr('src'));
      })
    }
  },
  "model-track[touchstart]" : function (el, ev) {
    $.axe(ev);
    $.stop(ev);

    var pt = $.getTouchPoints(ev);
    this.sx = pt.pageX; 
    this.sy = pt.pageY;

    var imageOffset = 0;
    var img = el.find('.model-source img[src="'+el.children('img').attr('src')+'"]');
    if (img[0]) {
      imageOffset = img.prevAll().length;
    }

    var oThis = this;
    var move = function (dx, dy) {
      var pos = dx;
      var posPercentage = 1.0 * pos / el.width();

      var images = el.find('.model-source img');
      var imagePos = Math.max(0, Math.min(images.length-1, imageOffset + Math.round(1.0 * posPercentage * images.length)));
      el.children('img').attr('src', images.eq(imagePos).attr('src'));
    };

    var up = function () {
    };

    var moveFunc = function (e) {

      var pt = $.getTouchPointChanges(e);
      if (!pt) { return; }
      // take the delta movement from mouse position changes
      var dx = pt.pageX - oThis.sx;
      var dy = pt.pageY - oThis.sy;

      move(dx, dy);
    };
    var upFunc = function (ev) {
      up();
      $(document.body).unbind("touchmove", moveFunc);
      $(document.body).unbind("touchend", upFunc);
    };
    
    $(document.body).bind("touchmove", moveFunc);
    $(document.body).bind("touchend", upFunc);
  }
})
