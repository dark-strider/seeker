$(function() {
  $('#seeker').on({
    change: GetMovies,
    submit: false,
  }).change();

  $('.section').each(function() {
    if ($(this)[0].scrollHeight > 334) {
      $(this).css('border-bottom','1px solid #cccccc');
      $(this).after("<a class='toggle-button upper'>More</a><div class='section-shadow'></div>");
    }
  });

  $('.toggle-button').click(function() {
    $(this).next('.section-shadow').toggle(0);
    $(this).prev('.section').toggleClass('section-full',0);
    $(this).text($(this).text() == 'Less' ? 'More' : 'Less');
    return false;
  });
});

function GetMovies() {
  var query = this.search.value;

  if (query && /\S/.test(query))
    $.get(this.action, $(this).serialize(), null, 'script');
  return false;
}

function GetPrices(id, name, director, year) {
  $.ajax({
    url: id+'/store/?name='+name+'&director='+director+'&year='+year,
    cache: false,
    success: function(result){
      $('#store_result').html(result);
      $('#buy_container').css('background-image','none');
    }
  });
  return false;
}