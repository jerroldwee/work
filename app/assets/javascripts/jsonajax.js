(function () {
  $.pjaxCallbacks = {};

  var a = 0; 
  $.jsonpjax = function (src, callback) { 
    a++;
    var funcName = "callback"+a; 
    $.pjaxCallbacks[funcName] = function(response){ callback(response); delete $.pjaxCallbacks[funcName] }

    var script = $("<script/>"); 
    script.attr('src', src+'?callback=' + funcName); 
    script.appendTo(document.body); 
  }
})();

// $.jsonpjax('http://somedomain.com:3000/welcome', function (data) {console.log(data)})

