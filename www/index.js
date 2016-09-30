// Generated by LiveScript 1.5.0
(function(){
  var check_clicked, sunetid_keydown, out$ = typeof exports != 'undefined' && exports || this;
  out$.check_clicked = check_clicked = function(){
    var sunetid;
    sunetid = $('#sunetid_input').val();
    if (sunetid == null || sunetid.length === 0) {
      alert('Please enter your SUNet ID');
      return;
    }
    $('#results_view').text('Fetching attendance records, please wait');
    return $.getJSON('/attendance?' + $.param({
      sunetid: sunetid
    }), function(results){
      var i$, len$, item;
      if (results.length === 0) {
        $('#results_view').html('No records of seminars attended for this user.<br>If any seminars are missing, please record your attendance at <a href="http://hci.st/547">http://hci.st/547</a>');
        return;
      }
      $('#results_view').html('');
      $('#results_view').append($('<div>').text('Attended the following seminars:'));
      $('#results_view').append('<br>');
      for (i$ = 0, len$ = results.length; i$ < len$; ++i$) {
        item = results[i$];
        $('#results_view').append($('<div>').text(item));
      }
      $('#results_view').append('<br>');
      return $('#results_view').append($('<div>').html('If any seminars are missing, please record your attendance at <a href="http://hci.st/547">http://hci.st/547</a>'));
    });
  };
  out$.sunetid_keydown = sunetid_keydown = function(event){
    if (event.keyCode === 13) {
      return check_clicked();
    }
  };
}).call(this);
