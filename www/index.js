// Generated by LiveScript 1.5.0
(function(){
  var check_clicked, out$ = typeof exports != 'undefined' && exports || this;
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
      var i$, len$, item, results$ = [];
      if (results.length === 0) {
        $('#results_view').text('No seminars attended');
        return;
      }
      $('#results_view').html('');
      for (i$ = 0, len$ = results.length; i$ < len$; ++i$) {
        item = results[i$];
        results$.push($('#results_view').append($('<div>').text(item)));
      }
      return results$;
    });
  };
}).call(this);
