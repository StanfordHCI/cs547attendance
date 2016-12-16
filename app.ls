require! {
  'fs'
  'getsecret'
  'koa'
  'koa-static'
  'koa-router'
  'koa-logger'
}

GoogleSpreadsheet = require 'google-spreadsheet'

debounce = require 'promise-debounce'

{
  cfy
  yfy
  add_noerr
} = require 'cfy'

kapp = koa()
kapp.use(koa-logger())
app = koa-router()

memoizeSingleAsync = (func) ->
  debounced_func = debounce yfy func
  cached_val = null
  return cfy ->*
    if cached_val?
      return cached_val
    result = yield debounced_func()
    cached_val := result
    return result

sleep = cfy (time) ->*
  sleep_base = (msecs, callback) -> setTimeout(callback, msecs)
  yield yfy(sleep_base)(time)

to_dict_list = (cells) ->
  output = []
  header_cells = cells.filter (x) -> x.row == 1
  body_cells = cells.filter (x) -> x.row != 1
  col_to_name = {}
  for item in header_cells
    col_to_name[item.col] = item.value
  row_idx_to_contents = []
  for item in body_cells
    idx = item.row - 2
    name = col_to_name[item.col]
    value = item.value
    if !row_idx_to_contents[idx]?
      row_idx_to_contents[idx] = {}
    row_idx_to_contents[idx][name] = value
  return row_idx_to_contents

#creds = require('./google-generated-creds.json')
creds = JSON.parse getsecret('google_service_account')

get_sheet = memoizeSingleAsync cfy ->*
  doc = new GoogleSpreadsheet(getsecret('spreadsheet_id'))
  yield add_noerr -> doc.useServiceAccountAuth creds, it
  info = yield doc.getInfo
  sheet = info.worksheets[0]
  return sheet

get_spreadsheet_real = cfy ->*
  sheet = yield get_sheet()
  cells = yield sheet.getCells
  return to_dict_list(cells)

get_spreadsheet = null

do ->
  last_time_fetched = 0
  cached_spreadsheet_results = null

  get_spreadsheet := cfy ->*
    current_time = Date.now()
    if Math.abs(current_time - last_time_fetched) < 30000 # within the past 30 seconds
      return cached_spreadsheet_results
    cached_spreadsheet_results := yield get_spreadsheet_real()
    last_time_fetched := current_time
    return cached_spreadsheet_results

get_seminars_attended_by_user = cfy (sunetid) ->*
  sunetid = sunetid.trim().toLowerCase()
  spreadsheet = yield get_spreadsheet()
  output = []
  output_set = {}
  for line in spreadsheet
    cur_sunetid = line['SUNet ID']
    if not cur_sunetid?
      continue
    if cur_sunetid.trim().toLowerCase() != sunetid
      continue
    seminar = line['Which seminar are you currently attending?']
    if output_set[seminar]?
      continue
    output_set[seminar] = true
    output.push seminar
  return output

list_all_users = cfy ->*
  spreadsheet = yield get_spreadsheet()
  output = []
  output_set = {}
  for line in spreadsheet
    sunetid = line['SUNet ID'].trim().toLowerCase()
    if output_set[sunetid]?
      continue
    output.push sunetid
    output_set[sunetid] = true
  output.sort()
  return output

app.get '/attendance', ->*
  {sunetid} = this.request.query
  if not sunetid?
    this.body = JSON.stringify []
    return
  seminars = yield get_seminars_attended_by_user sunetid
  this.body = JSON.stringify seminars

app.get '/pass_nopass', ->*
  output = []
  all_users = yield list_all_users()
  for user in all_users
    seminars_attended = yield get_seminars_attended_by_user(user)
    passed = seminars_attended.length >= 9
    output.push "#{user}: #{passed}"
  this.body = output.join('\n')

/*
do cfy ->*
  results = yield get_seminars_attended_by_user('gkovacs')
  console.log results
  results = yield get_seminars_attended_by_user('gkovacs2')
  console.log results
*/
/*
do cfy ->*
  results = yield get_spreadsheet()
  console.log results
  results = yield get_spreadsheet()
  console.log results
  yield sleep(6000)
  results = yield get_spreadsheet()
  console.log results
*/

kapp.use(app.routes())
kapp.use(app.allowedMethods())
kapp.use(koa-static(__dirname + '/www'))
port = process.env.PORT ? 5000
kapp.listen(port)
console.log "listening to port #{port} visit http://localhost:#{port}"