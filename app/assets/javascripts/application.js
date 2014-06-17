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
//= require ga
//= require jquery
//= require jquery_ujs
//= require jquery.browser
//= require delegate
//# require turbolinks
//= require products
//= require visualtryon
//= require cart
//= require jquery.icheck


$(document).ready(function(){
  
  $('input').iCheck({
    checkboxClass: 'icheckbox_square-blue',
    radioClass: 'iradio_square-blue',
  }).on('ifToggled', function(event){
    if ($(event.target).hasClass('lens-radio')) {
      $.actor.getListener("lens-radio[change]")($(event.target));
    }
    if ($(event.target).hasClass('color-id-radio')) {
      $.actor.getListener("color-id-radio[change]")($(event.target));
    }
    $.actor.getListener("search-type[click]")($(event.target));
  });

  $(document.body).click(function (ev) {
    if (!$(ev.target).is('.glass-frame') && !$(ev.target).parents('.glass-frame:first')[0]) {
      $('.glass-frame').removeClass('active');
    }
  });


  var checkVisualTryOnLink = function () {
    var selectedItem = null;
    var s = (window.location+"");
    if (s.indexOf("users/visual_try_on")>=0 && s.indexOf("product_id=")>=0) {
      selectedItem = $('.upload-picture-button');
    }
    if (selectedItem) {
      var itemID = s.match(/product_id=([0-9]+)/)[1];
      if (itemID) {
        selectedItem.attr('itemid', itemID);
        $.actor.getListener("load-picture[click]")(selectedItem);
      }

      if (s.match(/male=1/) && !s.match(/female=1/)) {
        $('.visual-input.sample-man').val(1);
        $('.male-image').show();
        $('.female-image').hide();
      } else {
        $('.visual-input.sample-man').val(0);
        $('.male-image').hide();
        $('.female-image').show();
      }
    }
  };
  checkVisualTryOnLink();

});

App = {}

$(document).ready(function() {
  function updateStatusCallback() {
  }

  $.get("/facebook/details", function (info) {
    App = info;

    $.ajaxSetup({ cache: true });
    $.getScript('//connect.facebook.net/en_UK/all.js', function(){
      FB.init({
        appId: info.app_id,
        channelUrl: '/facebook/channel',
      });     
      FB.getLoginStatus(updateStatusCallback);
    });

  });
});