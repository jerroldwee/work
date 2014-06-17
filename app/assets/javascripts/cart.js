$.act({
  "update-cart-form[submit]" : function (form, ev) {
    $.stop(ev);

    $.post(form.attr('action'), form.serialize()+'&json=1', function (info) {
      $(".total-cart").text("("+info.total+")");
    });
  },
  "remove-quantity[click]" : function (el, ev) {
    var x = confirm("Remove this item?");
    if (x) {
      var quantityField = el.parents('.entry:first').find('.product-unit input');
      quantityField.val(0);

      $.actor.getListener("quantity-field[change]")(quantityField);
      $.actor.getListener("update-cart-form[submit]")(el.parents("form:first"));

      el.parents('.entry:first').remove();      
    }
  },
  "quantity-field[change]" : function (el, ev) {
    var amountField = el.parents('.entry').find('.product-amount');
    amountField.text("$"+parseFloat(amountField.attr('price')) * parseInt(el.val()));
    var form = el.parents("form:first");
    $.actor.getListener("update-cart-total[form]")(form);
  },
  "credit-field[change]" : function (el, ev) {
    var bonus = 0.5 * parseInt(el.val());
    var maxSubtotal = ($('.subtotal-amount').text()||"0").replace(/^\$\s*/,'');
    bonus = Math.min(bonus, parseFloat(maxSubtotal));
    $(".discount-amount").text("$ " + bonus);
    $(".discount-amount").attr("discount", bonus);

    var form = el.parents("form:first");
    $.actor.getListener("update-cart-total[form]")(form);
  },
  "update-cart-total[form]" : function (form) {
    var lineItems = form.find('.line-items .entry');
    var total = 0;
    for (var i = 0, len = lineItems.length; i < len; i++) {
      var lineItem = lineItems.eq(i);
      var qty = parseInt(lineItem.find(".product-unit input").val());
      var price = parseFloat(lineItem.find(".product-amount").attr('price'));
      total += qty * price;
    }
    total = Math.round(100*total)/100;

    $('.subtotal-amount').text("$" + total);
    var bonus = Math.min(total, parseFloat($('.discount-amount').attr('discount')||0));
    $('.total-amount').text("$" + (total-bonus));

    $.actor.getListener("update-cart-form[submit]")(form);
  },
  "lens-radio[change]" : function (el, ev) {
    var total = parseFloat($('.main-price').attr('price')) + parseFloat(el.attr('price'));
    $('.total-price').text("$ " + total);
  },
  "color-id-radio[change]" : function (el, ev) {
    var tab = $(".tab[color_id='"+el.val()+"']");
    $.actor.getListener("switch-tab[click]")(tab);
  },
  "switch-radio[click]" : function (el, ev) {
    var input = $("input[name='color_id'][value='"+el.attr('color_id')+"']");
    input[0].checked = true;
    $("input[name='color_id']").iCheck('update');
  },
  "upload-triggered[change]" : function (el, ev) {
    if (el.parent().find("input[type='radio']")[0]) {
      el.parent().find("input[type='radio']")[0].checked = true
    }
    $("[type='radio']").iCheck("update");
  },
  "shipping-country-dropdown[change]" : function (el, ev) {
    if (el.val()=="Singapore") {
      $(".sg-cost").show();
      $(".out-sg-cost").hide();
      $(".sg-cost input[type='radio']:first")[0].checked = true;
      $("input[type='radio']").iCheck("update");
    } else {
      $(".sg-cost").hide();
      $(".out-sg-cost").show();      
      if (!$('.out-sg-cost input[type="radio"]:checked')[0]) {
        $(".out-sg-cost input[type='radio']:first")[0].checked = true;
      }
      $("input[type='radio']").iCheck("update");
    }
  },
  "prescription-selector[change]" : function (el, ev) {
    var itemID = el.val();
    var fieldName = el.attr('inputname');

    if (itemID == "0") {
      $(".prescription-title").parent().show();
    } else {
      $.get("/prescriptions/"+itemID+"?json=1", function (data) {
        for (var k in data) {
          input = $("input[name='"+fieldName+"["+k+"]"+"']");
          input.val(data[k]);
        }
        input = $("input[name='"+fieldName+"[prescription_title]"+"']");
        input.val("");
        $(".prescription-title").parent().hide();
      });      
    }
  },
  "billing-selector[change]" : function (el, ev) {
    var itemID = el.val();
    var fieldName = el.attr('inputname');

    if (itemID == "0") {
    } else {
      $.get("/billing_addresses/"+itemID+"?json=1", function (data) {
        for (var k in data) {
          input = $("input[name='"+fieldName+"["+k+"]"+"']");
          console.log(fieldName)
          input.val(data[k]);
        }
      });      
    }
  }
})