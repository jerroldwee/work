$.act({
  "change-tab[click]" : function (el, ev) {
    var container = el.parents(".tab-wrapper:first").find(".tab-contents");
    var selectedContainer = container.children().eq(el.prevAll().length);

    // for contents
    selectedContainer.parent().children().removeClass('active');
    selectedContainer.addClass('active');

    var titleContainer = el.parents(".tab-wrapper:first").find(".title-containers");
    var selectedTitleContainer = titleContainer.children().eq(el.prevAll().length);

    var middleContainer = el.parents(".tab-wrapper:first").find(".middle-contents");
    var selectedMiddleContainer = middleContainer.children().eq(el.prevAll().length);

    // for middle contents
    selectedTitleContainer.parent().children().removeClass('active');
    selectedTitleContainer.addClass('active');

    // for middle contents
    selectedMiddleContainer.parent().children().removeClass('active');
    selectedMiddleContainer.addClass('active');

    // button or tab
    el.parent().children().removeClass('active');
    el.addClass('active');
  },

  "reload-page[mousedown]" : function (el, ev) {
    $.stop(ev);
  },

  "reload-page[click]" : function (el, ev) {
    var href = el.attr('href');
    var pageNumber = href.match(/page=[0-9]+/)[0].replace('page=', '');

    var data = el.parents('form:first').serialize();
    $.get("/products/partial_list?page="+pageNumber, data, function (content) {
        el.parents('.content-wrapper:first').html(content);
    });

    $.stop(ev);
  },
  "update-gender[mousedown]" : function (el, ev) {
    $.stop(ev);
  },
  "update-gender[click]" : function (el, ev) {
    if (!el.is('a')) {
        el = el.find('a:first');
    }

    var value = el.attr('value');
    el.parents('.choose-type:first').find('input:first').val(value);

    var li = el.parent();
    li.parents().children().removeClass('selected');
    li.addClass('selected');
    $.stop(ev);

    $.actor.getListener("reload-page[submit]")(el.parents('form:first'), ev);
  },
  "search-type[click]" : function (el, ev) {
    setTimeout(function () {
        $.actor.getListener("reload-page[submit]")(el.parents('form:first'), ev);
    }, 300);
  },
  "reload-page[submit]" : function (form, ev) {
    var selectedPaymentMethod = form.find("input[name='payment_type']:checked").val();
    if (selectedPaymentMethod == "paypal")
      form.find("input[name='action']").val("Make Payment");
    else
      form.find("input[name='action']").val("Confirm");
    var data = form.serialize();
    $.get("/products/partial_list?page=1", data, function (content) {
        form.find('.content-wrapper:first').html(content);
    });
  },
  "try-product[click]" : function (el, ev) {
    $.stop(ev);

    var uploadPicButton = el.parents('form:first').find('.upload-picture-button:first');

    uploadPicButton.attr('itemid', el.attr('itemid'));

    $.actor.getListener("load-picture[click]")(uploadPicButton, ev);

    if ($('.male-image')[0]) {
      $('.visual-input.item-id').val(null);
      $('.visual-input.title').val(null);
    }

    if (el.attr('male') == "1") {
      $('.visual-input.sample-man').val(1);
      $('.male-image').show();
      $('.female-image').hide();
    } else {
      $('.visual-input.sample-man').val(0);
      $('.male-image').hide();
      $('.female-image').show();
    }
  },
  "load-picture[click]" : function (el, ev) {
    if (!el.attr('itemid')) {
        $.stop(ev);
        $.axe(ev);
        alert("Please select one product");
    } else {
        $.actor.getListener("change-tab[click]")(el, ev);

        var colorContainer = el.parents('form:first').find('.frame-colours');
        var selectedItem = colorContainer.children('.selected');
        selectedItem.prevAll().remove();
        selectedItem.nextAll().remove();
        selectedItem.hide();

        var first = true;
        var itemID = el.attr('itemid');
        $.getJSON("/products/"+itemID+"/details", function (data) {
            for (var i = 0, len = data.colors.length; i < len; i++) {
                var color = data.colors[i];
                var clone = selectedItem.clone(true);
                clone.removeClass('selected');
                clone.attr('colorid', color[4]);
                clone.attr('src', color[3]);
                clone.find('a').text(color[1]);
                clone.find('img').attr('src', color[2]);
                clone.show();
                clone.appendTo(selectedItem.parent());

                if (first) {
                    first = false;
                    clone.addClass('selected');
                    $.actor.getListener("select-frame-color[click]")(clone);
                }
            }
            selectedItem.removeClass('selected');

            var form = el.parents('form:first');
            form.find(".visual-input.product-id").val(itemID);
        });

    }
  },
  "select-frame-color[click]" : function (el, ev) {
    $.stop(ev);
    if (el.is("a")) {
        el = el.parent();
    }
    var src = el.attr('src');

    el.parent().children().removeClass('selected');
    el.addClass('selected');

    var glassFrame = el.parents('form:first').find('.glass-frame');
    glassFrame.addClass('active');
    glassFrame.find("img").remove();

    var img = $("<img/>");
    img.attr('src', src);
    img.css({
        maxWidth : "100%",
        maxHeight : "100%"
    })
    img.prependTo(glassFrame);

    var form = el.parents('form:first');
    form.find(".visual-input.color-id").val(el.attr('colorid'));
  },

  "save-visual-try-on[click]" : function (el, ev) {
    if (el.hasClass('lock')) {
      return;
    }
    var form = $(document.body).find('form.visual-try-on:first');
    if (form.find('.visual-input.title').val()) {
      $.actor.getListener("confirm-save-visual-try-on[click]")(el, ev);
      return;
    }

    var overlay = $("<div/>");
    overlay.css({
      position : "absolute",
      width : "100%",
      height : "100%",
      top : "0%",
      left : "0%",
      background : "#000",
      opacity : 0.3
    });
    overlay.addClass('popup-overlay');
    overlay.attr('jsclass', 'close-overlay');
    overlay.appendTo(document.body);

    var div = $("<div/>");
    div.css({
      position : "absolute",
      width : 300,
      height : 60,
      marginLeft : -150,
      marginTop : -25,
      top : "50%",
      left : "50%",
      background : "#FFF",
      border : "1px solid #DDD",
      textAlign : "center"
    });
    div.addClass('popup-overlay');
    div.appendTo(document.body);
    div.html("Title of your Visual Try On photo?<br/><br/><input type='text' class='title simple-form-1-1' name='title' style='width : 230px;'/><input jsclass='confirm-save-visual-try-on' class='popup-button' type='submit' value='Save'/>");
  },

  "close-overlay[click]" : function (el, ev) {
    $(document.body).find('.popup-overlay').remove();
    $(document.body).find('.popup').remove();
  },

  "confirm-save-visual-try-on[click]" : function (el, ev) {
    $.axe(ev);
    var isPopup = false;
    if (el.hasClass('popup-button')) {
      isPopup = true;
    }
    if (isPopup) {
      var title = el.parent().find("input.title").val();
      $.actor.getListener("close-overlay[click]")();
    }

    var form = $(document.body).find('form.visual-try-on:first');
    if (isPopup) {
      form.find('.visual-input.title').val(title);
    }
    var data = form.serialize();
    form.find('.save-button').addClass('lock');
    var aLink = form.find('a.save-text');
    aLink.text('Saving...');

    $.post("/user_fit_rooms/save", data, function (info) {
      form.find('.save-button').removeClass('lock');
      aLink.text('Save');
      if (info && info.id) {
        form.find('.visual-input.item-id').val(info.id);
      }
    }).error(function () {
      form.find('.save-button').removeClass('lock');
      aLink.text('Save');
    });
  },

  "save-and-post-to-facebook[click]" : function (el, ev) {
    if (el.hasClass('lock')) {
      return;
    }

    var form = el.parents('form:first');
    var data = form.serialize();
    el.parents('form:first').find('.save-button').addClass('lock');
    el.find('a').text('Processing...');

    $.post("/user_fit_rooms/save", data, function (info) {
      el.parents('form:first').find('.save-button').removeClass('lock');
      el.find('a').text('Post to Facebook');
      if (info && info.id) {
        form.find('.visual-input.item-id').val(info.id);

        FB.ui(
          {
            method: 'feed',
            name: 'Post to Facebook',
            link: App.host + 'products/' + info.product_id,
            picture: App.host + info.image.replace(/^\//,''),
            description: 'Cool figo eyewear'
          },
          function(response) {
            if (response && response.post_id) {
              $.post("/facebook/posted", { post_id : response.post_id, wall_id : info.id }, function (userInfo) {
                if (userInfo && ("total_credit" in userInfo)) {
                  $(".total-credit").text(userInfo.total_credit);
                }
              });
              alert('Post was published.');
            } else {
              alert('Post was not published.');
            }
          }
        );

      }
    }).error(function () {
      el.parents('form:first').find('.save-button').removeClass('lock');
      el.find('a').text('Post to Facebook');
    });
  },

  "post-to-facebook[click]" : function (el, ev) {
    FB.ui(
      {
        method: 'feed',
        name: 'Post to Facebook',
        link: App.host + 'products/' + el.attr('itemid'),
        picture: App.host + el.attr('src').replace(/^\//,''),
        description: 'Cool figo eyewear'
      },
      function(response) {
        if (response && response.post_id) {
          $.post("/facebook/posted", { post_id : response.post_id, wall_id : el.attr('wallid') }, function (userInfo) {
            if (userInfo && ("total_credit" in userInfo)) {
              $(".total-credit").text(userInfo.total_credit);
            }
          });
          alert('Post was published.');
        } else {
          alert('Post was not published.');
        }
      }
    );
  },

  "invite-friends[click]" : function (el, ev) {
    FB.ui(
      {
        method: 'apprequests',
        title: 'Invite friends to app',
        message: 'Join figo app now!'
      },
      function(response) {
        var requestID = response.request;
        if (response && response.to) {
          var uids = [];
          for (var i = 0, len = response.to.length; i < len; i++) {
            var uid = response.to[i];
            uids.push(uid);
          }
          $.post("/facebook/invited", { request_id : requestID, to : uids.join(',') }, function (userInfo) {
            if (userInfo && ("total_credit" in userInfo)) {
              $(".total-credit").text(userInfo.total_credit);
            }
          });
          alert("Invitation has been sent");
        } else {
        }
      }
    );
  },

  "upload-button[change]" : function (el, ev) {
    var form = el.parents("form:first");
    window.counter = window.counter || 0;

    el.parent().find('a').text('Uploading...');

    form.attr('action', "/user_fit_rooms/save");

    (function (form) {
      var frameName = 'framesubmit' + counter++;
      var frame;        
      try {
          frame = $(document.createElement('<iframe name="'+frameName+'">'));
      } catch (ex) {
          frame = $(document.createElement('iframe'));
          frame.name= frameName;
      }
      
      frame.attr('name', frameName);
      frame.css({width:1,height:1,position:"absolute",top:-1000,left:-1000,visibility:"hidden"});
      frame.appendTo(document.body);
      frame.bind('load', function () {
        el.parent().find('a').text('Upload');
        el.val(null);
      });
      form.attr('target', frameName);
      form.get(0).onsubmit = function () {return false;}
      form.get(0).submit();
    })(form);

  },

  "delete-wall[click]" : function (el, ev) {

    var x = confirm("Are you sure?");
    if (x) {
      $.post("/users/delete_wall", { id : el.attr('itemid') }, function () {
        el.parents('.user-post').remove();
      })
    }
  }

});

function VisualTryOnDone(id, url) {
  $(".visual-photo img").attr('src', url);
  $(".visual-input.item-id").val(id);
};

$.act({
  "knob[mousedown]" : function (knob, ev) {
    $.axe(ev);
    $.stop(ev);
    
    var el = knob.parents('.glass-frame:first');
    el.parent().css('overflow', 'visible');
    var form = el.parents('form:first');

    var wdPercentage = parseInt(el.attr('wd').replace('%', ''));
    var hgPercentage = parseInt(el.attr('hg').replace('%', ''));
    var leftPercentage = parseInt(el.attr('left').replace('%', '')) + wdPercentage/2;
    var topPercentage = parseInt(el.attr('top').replace('%', '')) + hgPercentage/2;

    var xmul = parseInt(knob.attr('mul').split(',')[0]);
    var ymul = parseInt(knob.attr('mul').split(',')[1]);
    var percentageWRatio = xmul* 100.0 / el.parent().width();
    var percentageHRatio = ymul* 100.0 / el.parent().height();

    var pt = $.getTouchPoints(ev);
    this.sx = pt.pageX; 
    this.sy = pt.pageY;

    var oThis = this;
    var move = function (dx, dy) {
      var newWidth = Math.abs(wdPercentage + dx * percentageWRatio);
      var newHeight = Math.abs(hgPercentage + dy * percentageHRatio);

      var scaleX = Math.abs(newWidth / wdPercentage);
      var scaleY = Math.abs(newHeight / hgPercentage);
      var scale = Math.max(scaleX, scaleY);

      newWidth = Math.abs(wdPercentage * scale);
      newHeight = Math.abs(hgPercentage * scale);
              
      el.attr('left', (leftPercentage - (newWidth)/2) + '%');
      el.attr('top', (topPercentage - (newHeight)/2) + '%');
      el.attr('wd', newWidth + '%');
      el.attr('hg', newHeight + '%');
      el.css({
        left : el.attr('left'),
        top : el.attr('top'),
        height : el.attr('hg'),
        width : el.attr('wd')
      });
      form.find(".visual-input.left").val(el.attr('left').replace('%', ''));
      form.find(".visual-input.top").val(el.attr('top').replace('%', ''));
      form.find(".visual-input.width").val(el.attr('wd').replace('%', ''));
      form.find(".visual-input.height").val(el.attr('hg').replace('%', ''));
    };

    var up = function () {
      el.parent().css('overflow', 'hidden');
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
  "knob[touchstart]" : "knob[mousedown]",
  "image-resizer[mousedown]" : function (el, ev) {
    $.axe(ev);
    $.stop(ev);
    
    el.addClass('active');
    var form = el.parents('form:first');

    var leftPercentage = parseInt(el.attr('left').replace('%', ''));
    var topPercentage = parseInt(el.attr('top').replace('%', ''));

    var percentageWRatio = 100.0 / el.parent().width();
    var percentageHRatio = 100.0 / el.parent().height();

    var pt = $.getTouchPoints(ev);
    this.sx = pt.pageX; 
    this.sy = pt.pageY;

    var oThis = this;
    var move = function (dx, dy) {
      var newLeft = (leftPercentage + dx * percentageWRatio);
      var newTop = (topPercentage + dy * percentageHRatio);
              
      el.attr('left', newLeft + '%');
      el.attr('top', newTop + '%');
      el.css({
        left : el.attr('left'),
        top : el.attr('top')
      });
      form.find(".visual-input.left").val(el.attr('left').replace('%', ''));
      form.find(".visual-input.top").val(el.attr('top').replace('%', ''));

    };

    var up = function () {
      // EditorImageResizer.confirmResize(this.currentRatio);
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
  "image-resizer[touchstart]" : "image-resizer[mousedown]"
})
