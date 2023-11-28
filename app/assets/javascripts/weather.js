$(function() {
  $(document).on('ajax:complete', function(event) {
    var responseData = event.detail[0].response;
    var response = JSON.parse(responseData);
    $('#error-message, #cached-message').empty();

    if (!response.success) {
      // Display errors
      $('#error-message').html('<div class="alert alert-danger">' + response.error + '</div>');
      $('#temperature-container').hide();
    } else {
      // Display temperature
      var temperature = response.temperature;
      if (temperature === null) {
          var current = "No data found";
          var max = "No data found";
          var min = "No data found";
      } else {
          var current = temperature.current;
          var max = temperature.max;
          var min = temperature.min;
      }
      
      var cached = response.cached;

      $('#temperature-value').text(current);
      $('#min-value').text(min);
      $('#max-value').text(max);

      // Show temperature container
      $('#temperature-container').show();

      // Show cache message
      if (cached) {
          $('#cached-message').html('<p>Result served from cache</p>');
      } 
    }
  });
  
});