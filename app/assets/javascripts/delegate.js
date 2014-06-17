var agent = navigator.userAgent.toLowerCase();
$.iDevice = agent.indexOf('iphone') >= 0 || agent.indexOf('ipad') >= 0 || agent.indexOf('ipod') >= 0;
$.android = agent.indexOf('android') != -1 || ((agent.indexOf(' u;') != -1 && agent.indexOf('ubuntu;') < 0 && agent.indexOf('opera') == -1) && !$.iDevice);
$.isTouchBase = $.android || ("createTouch" in document); // || (("msPointerEnabled" in navigator) && navigator.msPointerEnabled); // http://blogs.msdn.com/b/ie/archive/2011/09/20/touch-input-for-ie10-and-metro-style-apps.aspx

(function() {

  $.act = function (specs, opts) {
    var aliasSpecs = {};
    var options = opts || {};
    for (var key in specs) {
      if (typeof specs[key] == 'string') {
        aliasSpecs[key] = specs[key];
      } else {
        var m = key.match(/\[[^\]]+\]/);
        if (m.length == 1) {
          var eventType = m[0].replace(/^\[/,'').replace(/\]$/,'');
          var klassName = key.replace(m[0], '');
          
          if (eventType == 'click' && $.isTouchBase) {          
            var mouseDownFunc = function (p) {
              if (!p.attr('touchfixed')) {
                p.attr('touchfixed','fixed');
                p.css('cursor', 'pointer');
                p.css('-webkit-tap-highlight-color', 'rgba(0,0,0,0)');
                p[0].addEventListener('mousedown', function(){});
                p[0].addEventListener('click', function(){});
              }
            };
            $.actor.listen("touchstart", klassName, mouseDownFunc, 'touch-click'); // only applicable for touch base
          }
                
          eventType = $.actor.adaptEventName(eventType);
          $.actor.listen(eventType, klassName, specs[key], options.subKlassName);               
        }
      }
    }
  
    $.actorAlias(aliasSpecs);
  }

  $.actorAlias = function(specs) {
    var delegateSpecs = {};
    var anySpec = false;
    for (var key in specs) {
      var func = $.actor.getListener(specs[key]);
      if (func) {
        anySpec = true;
        delegateSpecs[key] = func;      
      }
    }
    if (anySpec) {
      $.act(delegateSpecs);   
    }
  }

})();

(function() {
    $.delegate = function(specs) {
        return function(e) {
          var target = $(e.target);

          if (e.target.nodeType == 3) {
              target = $(e.target.parentNode);
          }
          
          while (target[0]) {
              var keys = target[0].attributes && target.attr('jsclass');
              if (keys) {
                  keys = keys.split(' ');
                  var len = keys.length;
                  for (var i = 0; i < len; i++) {
                      var key = keys[i];
                      if (specs[key]) {
                          specs[key](target, e);
                      }
                      if (e.pStopped) {
                          return;
                      }
                  }
              }
      
              // propagationStopped
              if (e.pStopped) {
                  return;
              }
              // delegatePropagationEnd
              if ((target[0] == null) || (target[0] == document)) {
                  target = $([]);
              } else {
                  target = target.parent();
              }
          }
        }
    };

    $.axe = function(e) {
        if (e) {
            e.pStopped = true;
        }
    }

    $.axeNextClick = function(e) {
        if (e) {
            e.pClickStopped = true;
        }
    }

    $.skipStop = function (e) {
      if (e) {
        e.skipStop = true;
      }
    }

    $.stop = function (e) {
      if (e && e.skipStop) {
        return;
      }
      if (e && e.stopPropagation) {
          e.stopPropagation();
          e.preventDefault();
      }
      if (e && e.preventManipulation) {
        e.preventManipulation();
      }
      if (e && e.originalEvent && e.originalEvent.preventManipulation) {
        e.originalEvent.preventManipulation();
      }
    }

})();


(function() {
    var actorListeners = {};

    $.actor = {
        // listeners: {},
        eventTypeBinded: {},
        eventTypeDelegate: {},

        isDocumentReady: false,
        documentUnbindedHandlers: [],

        gestureKlasses: {},
        getListener: function(scope) {
          var m = scope.match(/\[[^\]]+\]/);
          if (m.length == 1) {
            var eventType = m[0].replace(/^\[/, '').replace(/\]$/, '');
            var klassName = scope.replace(m[0], '');

            eventType = $.actor.adaptEventName(eventType);

            var self = this;
            if (actorListeners[eventType] && actorListeners[eventType][klassName]) {
              return actorListeners[eventType][klassName];
            } else {
              return function() {};
            }
          }
          return null;
        },

        listen: function(eventType, klassName, func, subKlassName) {
          this.initEventType(eventType);

          if (subKlassName) {
            var hash = {};
            if (!actorListeners[eventType][klassName]) {
              actorListeners[eventType][klassName] = function(){};
            }
            if (typeof actorListeners[eventType][klassName] == 'function') {
                hash = actorListeners[eventType][klassName].listenerHash;
                if (!hash) {
                    hash = {};
                    hash["base"] = actorListeners[eventType][klassName];
                }
            }
            hash[subKlassName] = func;

            var self = actorListeners[eventType];
            (function(self, klassName) {
                self[klassName] = function() {
                    for (var k in self[klassName].listenerHash) {
                        if (self[klassName].listenerHash[k]) {
                          self[klassName].listenerHash[k].apply(self, arguments);
                        }
                    }
                };
                self[klassName].listenerHash = hash;
            })(self, klassName);

          } else {
              if (actorListeners[eventType][klassName] && actorListeners[eventType][klassName].listenerHash) {
                  actorListeners[eventType][klassName].listenerHash["base"] = func;
              } else {
                  actorListeners[eventType][klassName] = func;
              }
          }
        },

        adaptEventName : function(eventType) {
            if (eventType == 'focus') {
                if ($.browser.msie) {
                    return 'focusin';
                } else if ($.browser.mozilla) {
                    return 'focus';
                } else {
                    return 'DOMFocusIn';
                }
            }
            if (eventType == 'blur') {
                if ($.browser.msie) {
                    return 'focusout';
                } else if ($.browser.mozilla) {
                    return 'blur';
                } else {
                    return 'DOMFocusOut';
                }
            }
            return eventType.replace('*', '');
        },

        initEventType: function(eventType) { // ASSIGNING LISTENER EVENT
            if (!actorListeners[eventType]) {
                actorListeners[eventType] = {};
            }
            if (!this.eventTypeDelegate[eventType]) {
                this.eventTypeDelegate[eventType] = $.delegate(actorListeners[eventType]);
            }
            this.bindEvtType(eventType);
        },

        bindEvtType: function(eventType) {
            if (!this.eventTypeBinded[eventType]) {
                if (this.isDocumentReady) {
                    this.eventTypeBinded[eventType] = true;

                    var bubbleType = !$.browser.msie && !("jQuery" in window) ? true : undefined;
                    
                    if ((/^DOM/).test(eventType)) {
                        if (!$.browser.msie) {
                            document.addEventListener(eventType, this.eventTypeDelegate[eventType], bubbleType);
                        }
                    } else if (eventType == 'submit') {
                        $(document.body).bind(eventType, this.eventTypeDelegate[eventType], bubbleType);
                    } else {
                      if ($.browser.msie) {
                        $(document).bind(eventType, this.eventTypeDelegate[eventType]);                        
                      } else {
                        $(document).bind(eventType, this.eventTypeDelegate[eventType], bubbleType);                        
                      }
                    }
                } else {
                    this.documentUnbindedHandlers.push(eventType);
                }
            }
        }
        
    };

    (function() {
        var self = $.actor;
        $(document).ready(function() {
            self.isDocumentReady = true;
            var len = self.documentUnbindedHandlers.length;
            for (var i = 0; i < len; i++) {
                var eventType = self.documentUnbindedHandlers[i];
                (function (eventType) {
                  self.bindEvtType(eventType);
                })(eventType);
            }
        });
    })();

})();

$.getTouchPoints = function (e, ignoreIE) {
  if (e.originalEvent) {
    e = e.originalEvent; // jQuery Event Wrapper
  }

  if ("changedTouches" in e) {

    if (e.changedTouches && e.changedTouches.length > 0) {
      return { pageX : e.changedTouches[0].pageX, pageY : e.changedTouches[0].pageY, identifier : e.changedTouches[0].identifier };
    }

    return null;  
  }
  return { pageX : e.pageX, pageY : e.pageY, identifier : ignoreIE ? (new Date()-1)+"" : (e.pointerId || (new Date()-1)+"") }; // IE never change its pointerId, doh
};

$.getTouchPointChanges = function (e) {
  if (e.originalEvent) {
    e = e.originalEvent; // jQuery Event Wrapper
  }

  if ("changedTouches" in e) {

    var touches = e.changedTouches;
    if (touches && touches.length > 0) {
      var len = touches.length;
      for (var i = 0; i < len; i++) {
        var touch = touches[i];
        return { pageX : touch.pageX, pageY : touch.pageY, identifier : touch.identifier };
      }
    }   
    return null;
  }

  return { pageX : e.pageX, pageY : e.pageY, identifier : e.pointerId || (new Date()-1)+"" };
}