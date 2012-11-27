$(document).ready(function() {
  
  // if localStorage is supported, intro animation only plays on first visit
  if (localStorage.visited == true || localStorage.visited == "true") {
    $('#inv').remove();
  }
  
  if (!localStorage.visited) {
    // intro animation
    $('#slogan').delay(1000).fadeIn(1000, function() {
      $('.navbar, #three-col, #footer').delay(1000).fadeTo(1000, 1);
      localStorage.visited = true;
    });
  }
  
  $('#three-col .span4').hover(function() {
    $(this).animate({ 'opacity': '1' });
    $(this).children('.caption').animate({ 'padding-bottom': '30px' });
  }, function() {
     $(this).animate({ 'opacity': '0.9' });
    $(this).children('.caption').animate({ 'padding-bottom': '15px' });
  });
  
});