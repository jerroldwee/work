// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery.browser
//= require delegate
//= require turbolinks

$(document).ready(function(){
  var menu = $('#menu'),
  menuLink = $('#menuLink'),
  layout = $('#layout'),
  toggleClass = function (element, className) {
      var classes = element.attr('class').split(/\s+/),
          length = classes.length,
          i = 0;

      for(; i < length; i++) {
        if (classes[i] === className) {
          classes.splice(i, 1);
          break;
        }
      }
      // The className is not found
      if (length === classes.length) {
          classes.push(className);
      }

      element.attr('class', classes.join(' '));
  };

  menuLink.click(function (e) {
      e.preventDefault();
      var active = 'active';
      toggleClass(layout, active);
      toggleClass(menu, active);
  });

  var checkAdminLink = function () {
    var selectedItem = null;
    var s = (window.location+"");
    if (s.indexOf("admin/products")>=0) {
      selectedItem = $('.admin-products');
    }
    if (s.indexOf("admin/promotions")>=0) {
      selectedItem = $('.admin-promotions');
    }
    if (s.indexOf("admin/settings")>=0) {
      selectedItem = $('.admin-settings');
    }
    if (s.indexOf("admin/orders")>=0) {
      selectedItem = $('.admin-orders');
    }
    if (s.indexOf("admin/lens")>=0) {
      selectedItem = $('.admin-lens');
    }
    if (s.indexOf("admin/users")>=0) {
      selectedItem = $('.admin-customers');
    }
    if (s.indexOf("admin/moderators")>=0) {
      selectedItem = $('.admin-moderators');
    }
    if (selectedItem) {
      selectedItem.parent().children().removeClass('navigator-selected');
      selectedItem.addClass('navigator-selected');
    }
  };
  checkAdminLink();
  $(document).on('page:change', checkAdminLink);

  var checkOrderStatusField = function() {
    var field = $(".order-status-field");
    if (field[0]) {
      $.actor.getListener("order-status[change]")(field);
    }    
  };
  checkOrderStatusField();
  $(document).on('page:change', checkOrderStatusField);
});



$.act({
  "drag-item[mousedown]" : function (el, ev) {
      this.target = el.parents('.reorder-item:first');
      this.target = this.target[0] ? this.target : el.parent();
      if (!this.target.hasClass('on-drag')) {
        this.reorderWrapper = el.parents('.reorder-wrapper:first');
        this.reorderWrapper = this.reorderWrapper[0] ? this.reorderWrapper : el.parent();

        this.anchor = $("<div class='anchor-line'></div>")
        this.anchor.insertBefore(this.target);
        this.ghost = $(this.target.get(0).cloneNode(true));
        this.ghost.appendTo(document.body);
        this.ghost.css({
          position : "absolute",
          top : this.target.offset().top,
          left : this.target.offset().left,
          width : this.target.width() - parseInt(this.target.css('padding-left')) - parseInt(this.target.css('padding-right')),
          zIndex : 90000
        });
        this.ghost.addClass('on-drag');
        this.ghost.addClass('ghost');
        this.target.css('opacity', 0.2);
        this.originalX = this.target.offset().left;
        this.originalY = this.target.offset().top;
        $.stop(ev);
        $.axe(ev);

        this.elements = this.target.parent().children('.reorder-item');
        this.prevInsert = $(this.target);
      }

      var pt = $.getTouchPoints(ev);
      this.sx = pt.pageX; 
      this.sy = pt.pageY;

      var oThis = this;
      var move = function (dx, dy) {
        if (oThis.ghost) {
          var py = oThis.originalY + dy;

          oThis.ghost.css({
            // left : oThis.originalX + dx,
            top : py
          });

          var insertTarget = $(null);
          for (var i = oThis.elements.length-1; i >= 0; i--) {
            var element = oThis.elements.eq(i);
            if (py < element.offset().top) {
              insertTarget = element;
            }
          }

          if (oThis.prevInsert.get(0) != insertTarget.get(0)) {
            if (insertTarget.get(0)) {
              oThis.anchor.insertBefore(insertTarget);
            } else {
              oThis.anchor.appendTo(oThis.target.parent());
            }
            oThis.prevInsert = insertTarget;
          }
        }
      };

      var up = function () {
        if (oThis.ghost) {
          oThis.target.insertBefore(oThis.anchor);
          oThis.ghost.remove();
          oThis.anchor.remove();
          oThis.target.css('opacity', 1.0);

          var ids = [];
          oThis.reorderWrapper.find('.reorder-item').each(function (i, el) {
            el = $(el);
            ids.push(el.attr('itemid'));
          });
          $.post(oThis.reorderWrapper.attr('reorderapi'), { ids : ids.join(',') });
          // $.triggerAction(oThis.reorderWrapper, "reorder");
        }
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
          
  }
});


$.act({
  "order-status[change]" : function (el, ev) {
    if (el.val() == "Delivery") {
      $(".delivery-tracking-form").show();
    } else {
      $(".delivery-tracking-form").hide();      
    }
  }
})