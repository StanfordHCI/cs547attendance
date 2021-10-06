# CS 547 attendance checker

Students can check their attendance at http://cs547check.herokuapp.com/ 

Alias for the above: http://hci.st/cs547check

Source code: https://github.com/gkovacs/cs547attendance

## At the start of the term

Visit https://dashboard.heroku.com/apps/cs547check/settings to manage. geza and msb have access and can add you as a collaborator.

Set the config variable `spreadsheet_id` to the spreadsheet id (it is just numbers and letters). Make sure the spreadsheet is shared with `google_service_account.client_email`. Do not change the config variable `google_service_account`

## At the end of the term

To see who passed and didn’t, visit http://cs547check.herokuapp.com/pass_nopass

To see just the list of non-passing students, visit http://cs547check.herokuapp.com/nopass 

To get the enrolled students who aren’t passing, download the enrolled students table on axess on the class roster sheet, it is a blue icon with a red arrow on the top-right corner of the table to the right of the “Find” button (it should be called `ps.xls`)

And then git clone the cs547attendance repo and move `ps.xls` into the directory and run `scripts/get_nonpassing_students`

```
git clone https://github.com/gkovacs/cs547attendance
cd cs547attendance
npm install -g yarn
yarn
cp ~/Downloads/ps.xls ./
./scripts/get_nonpassing_students
```

If you make modifications to `scripts/get_nonpassing_students.ls` then run [lscbin](https://www.npmjs.com/package/lscbin) to compile it:

```
yarn global add lscbin
lscbin
```

If you make modifications to `app.ls` then run [lsc](https://www.npmjs.com/package/livescript) to compile it:

```
yarn global add livescript
lsc -c app.ls
```

If you need to develop the app locally, make sure to copy the config vars to a local ".env" [file](https://drive.google.com/file/d/1Jh413O92qfgJ_V7a7aTtmjF8JF0mC-sL/view?usp=sharing). This should be in .gitignore -- careful not push it to Heroku!

To run locally:
```
heroku local web
```
and go to localhost:5000 in your browser. To bypass the authentication stuff when developing, comment out all the authentication code in app.js.

To deploy the app, commit your changes and follow directions [here](https://devcenter.heroku.com/articles/git). Then:
```
git push heroku
```
