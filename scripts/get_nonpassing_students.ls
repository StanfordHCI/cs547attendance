require! {
  cheerio
  fs
  co
}

fetch = require 'node-fetch'

co ->*
  $ = cheerio.load fs.readFileSync 'ps.xls' # not really an xls file despite extension
  enrolled_students = []
  for x in $('td')
    text = $(x).text().trim()
    if text.includes('@stanford.edu')
      enrolled_students.push text
  nopass_request = yield fetch('http://cs547check.herokuapp.com/nopass')
  nopass_text = yield nopass_request.text()
  nopass_students = nopass_text.split('\n').map((.trim())).map((+ '@stanford.edu'))
  nopass_students_set = {[x, true] for x in nopass_students}
  enrolled_nopass_students = enrolled_students.filter(-> nopass_students_set[it])
  console.log enrolled_nopass_students
