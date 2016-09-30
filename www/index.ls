export check_clicked = ->
  sunetid = $('#sunetid_input').val()
  if not sunetid? or sunetid.length == 0
    alert 'Please enter your SUNet ID'
    return
  $('#results_view').text 'Fetching attendance records, please wait'
  results <- $.getJSON '/attendance?' + $.param({sunetid})
  if results.length == 0
    $('#results_view').html 'No records of seminars attended for this user.<br>If any seminars are missing, please record your attendance at <a href="http://hci.st/547">http://hci.st/547</a>'
    return
  $('#results_view').html ''
  $('#results_view').append $('<div>').text('Attended the following seminars:')
  $('#results_view').append '<br>'
  for item in results
    $('#results_view').append $('<div>').text(item)
  $('#results_view').append '<br>'
  $('#results_view').append $('<div>').html('If any seminars are missing, please record your attendance at <a href="http://hci.st/547">http://hci.st/547</a>')
