export check_clicked = ->
  sunetid = $('#sunetid_input').val()
  if not sunetid? or sunetid.length == 0
    alert 'Please enter your SUNet ID'
    return
  $('#results_view').text 'Fetching attendance records, please wait'
  results <- $.getJSON '/attendance?' + $.param({sunetid})
  if results.length == 0
    $('#results_view').text 'No seminars attended'
    return
  $('#results_view').html ''
  for item in results
    $('#results_view').append $('<div>').text(item)
