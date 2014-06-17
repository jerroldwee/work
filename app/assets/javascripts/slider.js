Slideshow = {
  jumpTo : function (container, targetX) {
    var wd = container.width();
    var nodes = container.children();
    for (var i = 0, len = nodes.length; i < len; i++) {
      var node = nodes.eq(i);
      node.css('left', (i * wd + targetX)+'px');
    }

    var parentContainer = Slideshow.slideshowContainer(container);
    if (parentContainer.hasClass('paralax')) {
      var targetN = (targetX/Math.max(1,wd*nodes.length));
      var targetBgPosition = 50 + (-targetN * 50);
    }
    if (parentContainer.hasClass('paralax')) {
      parentContainer.css('background-position', targetBgPosition + '% 0px');
    }
  },
  animateTo : function (container, targetN) {
    targetN = Math.max(0, Math.min(container.children().length-1, targetN));

    var parentContainer = this.slideshowContainer(container);
    var currentDragID = parentContainer.attr('dragid');

    var bullets = parentContainer.find('.slider-control').children();
    var bullet = bullets.eq(Math.abs(targetN));
    if (bullet[0]) {
      bullets.removeClass('active');
      bullet.addClass('active');
    }

    var hash = {
      target : container,
      parentContainer : parentContainer,
      currentX : -Slideshow.currentOffset(container),
      targetX : targetN * container.width()
    };

    container.css('height', container.children().eq(targetN).height());
    container.attr('lastindex', targetN);

    var timeout = 10;
    var maxT = 300.0;
    var realD = Math.abs(hash.targetX-hash.currentX);
    var cappedD = Math.min(container.width(), realD);
    var totalT = 1.0 * maxT * cappedD / container.width();
    var startT = new Date();

    hash.inc = Math.round(Math.max(5, 1.0*totalT/timeout*(realD/cappedD)));

    var updateLoc = (function (self, currentDragID) {
      return function () {
        if (self.parentContainer.attr('dragid') == currentDragID) {
          var t = Math.max(0, Math.min(1, 1.0 * (new Date() - startT) / Math.max(1, totalT)));
          if (Math.abs(self.targetX - self.currentX) <= self.inc) {
            self.currentX = self.targetX;
          } else {
            // self.currentX += self.inc * (self.targetX - self.currentX < 0 ? -1 : 1);
            self.currentX = self.currentX + t * (self.targetX - self.currentX);
            setTimeout(self.updateLoc, timeout);
          }
          Slideshow.jumpTo(self.target, Math.round(-self.currentX)); 
        }
      }
    })(hash, currentDragID);

    hash.updateLoc = updateLoc;
    setTimeout(hash.updateLoc, timeout);
  },
  slideshowContainer : function (container) {
    return container.parents('.slider-container:first');
  },
  initContainer : function (container) {
    var parentContainer = Slideshow.slideshowContainer(container);
    if (!container.hasClass('slider-activated')) {
      var nodes = container.children();
      container.css('height', nodes.eq(0).height());

      container.addClass('slider-activated');
      parentContainer.find('.slider-control').addClass('slider-control-activated');
    }
    this.slideshowContainer(container).attr('dragid', (new Date()-1) + "");
  },
  currentOffset : function (container) {
    return container.children(':first').offset().left - container.offset().left;
  },
  currentIndex : function (container) {
    return Math.round(Math.abs(this.currentOffset(container))/container.width());
  }
}

$.act({
  "slideshow-drag[mousedown]" : function (el, ev) {
    Slideshow.initContainer(el);

    this.target = el;
    this.width = this.target.width();
    this.currentOffset = 0;
    this.lastDx = 0;
    this.lastMoveDx = 0;

    if (this.target.children().length > 0) {
      this.currentOffset = Slideshow.currentOffset(this.target);
      Slideshow.jumpTo(this.target, Math.round(this.currentOffset)); 
    }

    $.axe(ev);

    if (ev.target.nodeName.toLowerCase() == 'img') {
      $.stop(ev);
    }

    var pt = $.getTouchPoints(ev);
    this.sx = pt.pageX; 
    this.sy = pt.pageY;

    var oThis = this;
    var move = function (dx, dy) {
      if (dx != oThis.lastDx) {
        Slideshow.jumpTo(oThis.target, Math.round(oThis.currentOffset+dx)); 
      }

      var v = dx - oThis.lastDx;
      oThis.lastMoveDx = v != 0 ? v : oThis.lastMoveDx;
      oThis.lastDx = dx;
    };

    var up = function () {
      oThis.currentX = oThis.currentOffset + oThis.lastDx;
      var method = oThis.lastMoveDx < 0 ? "floor" : (oThis.lastMoveDx > 0 ? "ceil" : "round");
      var targetN = -Math.max(-(oThis.target.children().length-1), Math.min(0, Math[method](1.0 * oThis.currentX / oThis.width)));

      Slideshow.animateTo(oThis.target, targetN);
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
      $(document.body).unbind("mousemove", moveFunc);
      $(document.body).unbind("mouseup", upFunc);
      $(document.body).unbind("touchmove", moveFunc);
      $(document.body).unbind("touchend", upFunc);
    };

    $(document.body).bind("mousemove", moveFunc);
    $(document.body).bind("mouseup", upFunc);      
    $(document.body).bind("touchmove", moveFunc);
    $(document.body).bind("touchend", upFunc);      
  },
  "slideshow-drag[touchstart]" : "slideshow-drag[mousedown]",
  "slideshow-jump-to[click]" : function (el, ev) {
    var targetN = el.prevAll().length;
    var container = Slideshow.slideshowContainer(el).find('.slider:first');
    Slideshow.initContainer(container);
    Slideshow.animateTo(container, targetN);
  },
  "slideshow-next[click]" : function (el, ev) {
    var container = Slideshow.slideshowContainer(el).find('.slider:first');
    Slideshow.initContainer(container);
    Slideshow.animateTo(container, Slideshow.currentIndex(container)+1);    
  },
  "slideshow-prev[click]" : function (el, ev) {
    var container = Slideshow.slideshowContainer(el).find('.slider:first');
    Slideshow.initContainer(container);
    Slideshow.animateTo(container, Slideshow.currentIndex(container)-1);    
  }
});

$(window).resize(function () {
  $(document.body).find('.slider').each(function (i, el) {
    el = $(el);
    if (el.hasClass('slider-activated')) {
      var container = Slideshow.slideshowContainer(el).find('.slider:first');
      Slideshow.initContainer(container);
      var targetN = parseInt(container.attr('lastindex'));
      Slideshow.jumpTo(container, - targetN * container.width());      
      container.css('height', container.children().eq(targetN).height());
    }
  });
});