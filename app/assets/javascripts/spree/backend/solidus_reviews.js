//= require jquery-bar-rating
//= require spree/backend

$(document).on('ready', function () {
  $.each($("select.review-stars"), function(index, value) {
    selectTag = $(value)
    selectTag.barrating(selectTag.data("barrating-options"))
  });
});
