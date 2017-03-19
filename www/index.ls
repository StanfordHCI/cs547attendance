substitutions = {
  '02/10: TBD': '02/10: Alex Leavitt'
  '03/10: TBD': '03/10: Shumin Zhai'
}

fix_input_string = (input_string) ->
  return substitutions[input_string] ? input_string

leftpad_to_two = (num) ->
  if 0 <= num <= 9
    return '0' + num
  return num.toString()

export sorted_by_date = (input_strings) ->
  output = []
  for input_string in input_strings
    if not input_string?trim?
      continue
    input_string = input_string.trim()
    input_string = fix_input_string(input_string)
    colon_idx = input_string.indexOf(':')
    if colon_idx == -1
      colon_idx = input_string.indexOf('-')
    if colon_idx == -1
      output.push input_string
      continue
    date = input_string.substr(0, colon_idx)
    remainder = input_string.substr(colon_idx)
    if date.indexOf('/') == -1
      output.push input_string
      continue
    [month,day] = date.split('/')
    if not month? or not day?
      output.push input_string
      continue
    month = parseInt(month.trim())
    day = parseInt(day.trim())
    if isNaN(month) or isNaN(day)
      continue
    date_new = leftpad_to_two(month) + '/' + leftpad_to_two(day)
    output.push(date_new + remainder)
  output.sort()
  return output
    

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
  for item in sorted_by_date(results)
    $('#results_view').append $('<div>').text(item)
  $('#results_view').append '<br>'
  $('#results_view').append $('<div>').html('If any seminars are missing, please record your attendance at <a href="http://hci.st/547">http://hci.st/547</a>')

export sunetid_keydown = (event) ->
  if event.keyCode == 13
    check_clicked()

$(document).ready ->
  $('#sunetid_input').focus()