    $(document).ready(init);

function init() {
  /* ========== DRAWING THE PATH AND INITIATING THE PLUGIN ============= */

    var radius = 500;
  $.fn.scrollPath("getPath")
    // Arc down and line to 'syntax'
    .arc(radius, 0, radius, -Math.PI,  Math.PI, true,
            {rotate:2*Math.PI}
            )
    .moveTo(0,0)
    ;

// setup the scroll-box contents

  var numCards = $(".card").length;
  $(".card").each( function (i, card) {

      $(card).css({
          "left": Math.round((1-Math.cos(Math.PI*2*i/numCards))*radius),
          "top": Math.round(Math.sin(Math.PI*2*i/numCards)*radius) ,
          "-webkit-transform":"rotate(-"+Math.round(360*i/numCards)+"deg) translateX("+Math.round(-$(card).width()/1.5)+"px) translateY("+Math.round(-$(card).height()/2)+"px)",
          "-webkit-transform-origin":"0 0",
          "-moz-transform":"rotate(-"+Math.round(360*i/numCards)+"deg) translateX("+Math.round(-$(card).width()/1.5)+"px) translateY("+Math.round(-$(card).height()/2)+"px)",
          "-moz-transform-origin":"0 0"
      });


  });

  // We're done with the path, let's initate the plugin on our wrapper element
    $(".scrollwrapper").scrollPath({
        drawPath:   true,
        wrapAround: true,
      scrollBar:  true
  });

  // Add scrollTo on click on the navigation anchors
  $("nav").find("a").each(function() {
    var target = this.getAttribute("href").replace("#", "");
    $(this).click(function(e) {
      e.preventDefault();

      // Include the jQuery easing plugin (http://gsgd.co.uk/sandbox/jquery/easing/)
      // for extra easing functions like the one below
      $.fn.scrollPath("scrollTo", target, 1000, "easeInOutSine");
    });
  });

}
