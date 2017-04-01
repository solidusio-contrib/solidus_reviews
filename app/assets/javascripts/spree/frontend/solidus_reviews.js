//= require jquery.barrating
//= require spree/frontend

$(document).on('ready', function () {
  $.each($("select.review-stars"), function(index, value) {
    selectTag = $(value)
    selectTag.barrating(selectTag.data("barrating-options"))
  });
});
