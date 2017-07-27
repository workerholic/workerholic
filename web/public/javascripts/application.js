$(document).ready(function() {
  var tab = $(location).attr('href').split('/').pop();
  var $active = $('a[href=' + tab + ']');
  $active.css('background', '#a2a2a2');
  $active.css('color', '#fff');
});
