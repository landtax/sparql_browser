var facet_selector = function($spec, my) {
  var $that;

  my = my || {};
  $that = $spec;

  $that.change(function() {
    window.location.replace($that.val());
  });

}
