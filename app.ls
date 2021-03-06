require! {
  'fs'
  'getsecret'
  'koa'
  'koa-static'
  'koa-router'
  'koa-logger'
  'glob'
  'getsecret'
}

on_heroku = process.env.PORT?
if not on_heroku
  selfSignedHttps = require('self-signed-https')

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

bodyParser = require('koa-bodyparser')
kapp.use(bodyParser({extendTypes: {json: ['json', '**/json']}}))

#session = require('koa-session')
session = require('koa-generic-session')
kapp.keys = [getsecret('session_keys')]
#kapp.use(session({}, kapp))
#kapp.use(session({key: 'test.cookie'}))
kapp.use(session({key: 'test.cookie'}))

passport = require 'koa-passport'

kapp.use passport.initialize()
kapp.use passport.session()

/*
idps = {
  'itlabv2': {
    entityID:     'https://idp.itlab.stanford.edu/idp/shibboleth',
    description:  'Stanford IT Lab IdP',
    entryPoint:   'https://idp.itlab.stanford.edu/idp/profile/SAML2/Redirect/SSO',
    cert:         [
      'MIIDQzCCAiugAwIBAgIUKuSXppluIJvYiroHZCb9QRi6uh0wDQYJKoZIhvcNAQEF',
      'BQAwITEfMB0GA1UEAxMWaWRwLml0bGFiLnN0YW5mb3JkLmVkdTAeFw0xMzA3MTAx',
      'NzU3MzhaFw0xNjA3MTAxNzU3MzhaMCExHzAdBgNVBAMTFmlkcC5pdGxhYi5zdGFu',
      'Zm9yZC5lZHUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCz67jrUj+n',
      'q3NemgxSbA4uOz9cLaZToM3uED7xy/vyFlbv8Od9i55NQSrjdDufRI/TmTI52IkI',
      'X89wyeBspyP4jOy4y3EvQtFtVlXhHiTEdsvDn87E6esl3ouhR5nUY5zH7GwJp9zp',
      'Jr3D56JGR2QpVtFbSFZbIMa6uhb9ToYNsByJeFasLWojcn1ycUrj8p8ZFk1aZio7',
      'VhJlPVdokJAhlqhlnkkZGIJHpgId0EOVrSfUNU8BdFJHlUkpvsJB3WViibLe9a5w',
      'clDVMpkMA+gapfx3Zp0ytEIIG1qv0eQe9oAb45IUYatT0JYGzgTU4pClGwimQTVm',
      'NI0dvafvyqBjAgMBAAGjczBxMFAGA1UdEQRJMEeCFmlkcC5pdGxhYi5zdGFuZm9y',
      'ZC5lZHWGLWh0dHBzOi8vaWRwLml0bGFiLnN0YW5mb3JkLmVkdS9pZHAvc2hpYmJv',
      'bGV0aDAdBgNVHQ4EFgQU9PDx6le/7k8fXsH3Qp3uaam/Jd8wDQYJKoZIhvcNAQEF',
      'BQADggEBAKpsyW92XzEVgNwdapcejQTjF0Ccp0/DSoZSaK9oCuxTVQHvhN+mJuO+',
      'Mu94gmX6BQ+GjGQAxbTwENrxa//pneJCQpBKkXJXjBMpuvFUvnthG34KZMXVqsdt',
      'kVuc9QwFULs/BPnT0RC88DsKL/WxLmUSLDjfEzD1nQSVyDeQYd71wHjETkGow/1c',
      'bgaBra/+Gsj1e+2Lbj1HzMfeul4/QP0hV44ZXqq1ujM8vt9lcNYbS6iPJp2pdZLP',
      'GeVOsy8jsPGYMGLqoETHAci6RRFdqxZ/GBIU0XhDj7K8UBnFuD+DeiyAzIPnW6jI',
      'gIQ5o+W6Gb+K09XbVhKRTkwJ7WMimYk=',    
    ].join(' '),
  },

  'itlab': {
    entityID:     'https://weblogin.itlab.stanford.edu/idp/shibboleth',
    description:  'Stanford IT Lab IdP V3', 
    entryPoint:   'https://weblogin.itlab.stanford.edu/idp/profile/SAML2/Redirect/SSO',
    cert:         [
      'MIIDVzCCAj+gAwIBAgIUZn2ik8sAxxolY3yWAiMEI8BvhlswDQYJKoZIhvcNAQEL',
      'BQAwJjEkMCIGA1UEAwwbd2VibG9naW4uaXRsYWIuc3RhbmZvcmQuZWR1MB4XDTE2',
      'MDQxMjIzNTE0NloXDTM2MDQxMjIzNTE0NlowJjEkMCIGA1UEAwwbd2VibG9naW4u',
      'aXRsYWIuc3RhbmZvcmQuZWR1MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC',
      'AQEAo+kp4ulof1snw/+0FsjKlUgZkErKhfgI39g/xB5ZXlKbK5f0f3frvzaT+J+h',
      'RrlROf4rjtYzJA/n/QGRImfjg24jI6dILOzZnV9pLmilntqJhPN9SgoBVQp/N0sl',
      'MXVu3vwVAzhVs0y61CQCmG3EI5xCwHuiMPgf8qNeGUX+ilb8GU0xtoBALG+S+v12',
      'BefNtPzU7pnuf4yx8HfOX64nCsLf1bqeaFust5W4XRSxBvIeGZRs3/6i3+/FrbMQ',
      'pZS7c9EeXDZ720SYTJjGcKO9NdfeHoluIJPjHmveejeQtzOwWqdq1NvyyQh33nAM',
      'zfSAgVYiPQ+TFT5ouMmA7ZcFlQIDAQABo30wezAdBgNVHQ4EFgQUyEXYaofjFhkc',
      '0musYcKHCw4R6PUwWgYDVR0RBFMwUYIbd2VibG9naW4uaXRsYWIuc3RhbmZvcmQu',
      'ZWR1hjJodHRwczovL3dlYmxvZ2luLml0bGFiLnN0YW5mb3JkLmVkdS9pZHAvc2hp',
      'YmJvbGV0aDANBgkqhkiG9w0BAQsFAAOCAQEAbPdOcVvylLYSszmLA6PluxeLRLmk',
      'UEx05akEKaLSX+WOe8DDnZuA4I8Xh9zPM//t+g0B037btF/cpccCQlPYONYQcTA+',
      '24UIhgqZcOTtFr9pphD2xWdjkzQooIKwEnQEjM50BGVTfZYj3+eUN2rJw/gjKVR5',
      'hZejZMc4aZXcObg12/rFISzEtHAtRU+oBcNWnMADNiIRHEBsKwzSucH+Hmn8faeY',
      't/8HLLLtVeXmZSL80UNl1vpmTXCz/SMRU6QlTttyhKlNS/scmNc9fzJjiyGPFvmg',
      'jyAD3XPzS1BJ6xEJJII5e86zpoKISHoFA8AA1uW8N3uuB4RqL2Mr55moeA==',
    ].join(' ')
  },

  'dev': {
    entityID:     'https://idp-dev.stanford.edu/',
    description:  'Stanford University Development IdP',
    entryPoint:   'https://idp-dev.stanford.edu/idp/profile/SAML2/Redirect/SSO',
    cert:         [
      'MIIDvTCCAqWgAwIBAgIJAJ92DcTnMwPtMA0GCSqGSIb3DQEBCwUAMHUxCzAJBgNV',
      'BAYTAlVTMRMwEQYDVQQIDApDYWxpZm9ybmlhMREwDwYDVQQHDAhTdGFuZm9yZDEf',
      'MB0GA1UECgwWQWRtaW5pc3RyYXRpdmUgU3lzdGVtczEdMBsGA1UEAwwUaWRwLWRl',
      'di5zdGFuZm9yZC5lZHUwHhcNMTQxMjAxMjE1NjQxWhcNMjQxMTMwMjE1NjQxWjB1',
      'MQswCQYDVQQGEwJVUzETMBEGA1UECAwKQ2FsaWZvcm5pYTERMA8GA1UEBwwIU3Rh',
      'bmZvcmQxHzAdBgNVBAoMFkFkbWluaXN0cmF0aXZlIFN5c3RlbXMxHTAbBgNVBAMM',
      'FGlkcC1kZXYuc3RhbmZvcmQuZWR1MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB',
      'CgKCAQEAwV1Z6ePsQUGvrns6plDY0As6N1l2WmKIjpF7csKVILJuGrXN7A0xkMML',
      'Ib0mwHv3riL/ufsuZxeXOa4s49L3a3NYnkHfpmii1n3DduGY08sEVow7wBxs1Tu8',
      'gssE/sqNCIBY/j2CxJfLmbTgUhev95MQxgEYUE77xRLWuRnJjws/d3Azb9JBQlmu',
      'xXM7vf8BAIG/+1eunXkjRyzFphuJK+YrImI56l0gTOdTYvzsRP614sZ0YAXa4pJq',
      'phDCapXmVUJgOg8EXC9Hdlg6iN2qOzjYooH1MkpE/vyUZCkDA/rhHkumpnEgvZwD',
      'PJpe+5o4sPMBcYZsGEpMLDzprcybDQIDAQABo1AwTjAdBgNVHQ4EFgQUdX/dnGei',
      'OH0BcJCBkVlVYTK3jZkwHwYDVR0jBBgwFoAUdX/dnGeiOH0BcJCBkVlVYTK3jZkw',
      'DAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAQEARgf8AWi+dHfGHbgrJdYL',
      '6avhaK+X5hWCecXTK7pK4ylHsetc3Os8YcyioFKN+UJ3rLfm6Ldl7M1AqgA6rNHJ',
      '/K65L4NHLnW+d8rQYqPPQNKg3uksuRBTf7OcrlVbmBOjWNoZe7SBTZ2s/rbprzdB',
      '+x0rfY9wGuTEYNpV0KYINbUIQdQbNp4Ccn4xiOuOhdAJtv/xgb4NlnRLsh3xctZ3',
      'gh1rgq2lcu8gRVrQbrCcx9EnfTK2qMKBLkdxdsWXq8j+yXZ27B7Wxvf8pH32JtIB',
      '6wRJeFBVf0B3GZtQ8aPhik245oh2HX4VuFoyeGUbzHGcS6xQRMWFrxNF2aSBW1Ld',
      '7w=='
    ].join(' '), 
  },

  'uat': {
    entityID:     'https://idp-uat.stanford.edu/',
    description:  'Stanford University UAT IdP',
    entryPoint:   'https://idp-uat.stanford.edu/idp/profile/SAML2/Redirect/SSO',
    cert:         [
      'MIIDzDCCArQCCQCdJebZPEsQBzANBgkqhkiG9w0BAQsFADCBpzELMAkGA1UEBhMC',
      'VVMxEzARBgNVBAgMCkNhbGlmb3JuaWExETAPBgNVBAcMCFN0YW5mb3JkMRwwGgYD',
      'VQQKDBNTdGFuZm9yZCBVbml2ZXJzaXR5MTMwMQYDVQQLDCpBdXRoZW50aWNhdGlv',
      'biBhbmQgQ29sbGFib3JhdGlvbiBTb2x1dGlvbnMxHTAbBgNVBAMMFGlkcC11YXQu',
      'c3RhbmZvcmQuZWR1MB4XDTE2MDUyMzIwMTIxMVoXDTI2MDUyMTIwMTIxMVowgacx',
      'CzAJBgNVBAYTAlVTMRMwEQYDVQQIDApDYWxpZm9ybmlhMREwDwYDVQQHDAhTdGFu',
      'Zm9yZDEcMBoGA1UECgwTU3RhbmZvcmQgVW5pdmVyc2l0eTEzMDEGA1UECwwqQXV0',
      'aGVudGljYXRpb24gYW5kIENvbGxhYm9yYXRpb24gU29sdXRpb25zMR0wGwYDVQQD',
      'DBRpZHAtdWF0LnN0YW5mb3JkLmVkdTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC',
      'AQoCggEBAJlkwhaVvmjhW6EGIATvco0UQntR1p9+XneAU7z08j3CLyjgb5n7qTgn',
      '3piZmENA0y3aD9cvIZ6ixYN8oCGfPTjwMr488cCQsBkvXCoA4O1XThvPsdd5KjQX',
      'y8IAsno6qrYsfeS+nlMgeJhHVPRRFkos+JUs0LGYHK/vZdMpIVYhDbH3udwjMP9O',
      'Qf4h1HCr4zy2n/XWg3GO9AyKq50ibTogOZy0wQr7gp1+l5RW0hXG1IYShbu57MaI',
      'TtsUZUMUJZGGGeEBYANWelJ8TnXvOJt0ZqLeULJSgCS8EyKQM4Ty5Qy7cbTVN8zP',
      'aPne4smCvpeAHxyaCqx3z6XXBgKutDcCAwEAATANBgkqhkiG9w0BAQsFAAOCAQEA',
      'DxXtRxiUAd9brr55fv0gxMFNTE7ayZh5BWFgukOvMyS0H1ces7NmiqoDJR3uMc7P',
      '1zdudiAoO4tlRGnMm9FA5eE8Rhm8WEPvwdaGcoiIu80yPXPHWx+7sBy4mAc4llrO',
      'AYwCbXM0E6jLh4Y068j+mLmzYzkW6Ro7mImTyGNYNWJUr3jP+79m6Fr0QbC44Giz',
      'S4UszE26axYpmhs2ONQFsOBs1VazgNt/LJfgQXK3MpdRct2vOMIeHSJAw6lJ1rfc',
      'CoS3z3uvz7LPaJdw4ZyDC9i0bQoKvfpi96pOnsc2TE/MMo3JbG2vW8g0G3f9xv5O',
      'PzwNr2FQZzZfjH0wg9dMfQ=='
    ].join(' '),
  },

  'prod': {
    entityID:     'https://idp.stanford.edu/',
    description:  'Stanford University WebAuth',
    entryPoint:   'https://idp.stanford.edu/idp/profile/SAML2/Redirect/SSO',
    cert:         [
      'MIIDnzCCAoegAwIBAgIJAJl9YtyaxKsZMA0GCSqGSIb3DQEBBQUAMGYxCzAJBgNV',
      'BAYTAlVTMRMwEQYDVQQIDApDYWxpZm9ybmlhMREwDwYDVQQHDAhTdGFuZm9yZDEU',
      'MBIGA1UECgwLSVQgU2VydmljZXMxGTAXBgNVBAMMEGlkcC5zdGFuZm9yZC5lZHUw',
      'HhcNMTMwNDEwMTYzMTAwWhcNMzMwNDEwMTYzMTAwWjBmMQswCQYDVQQGEwJVUzET',
      'MBEGA1UECAwKQ2FsaWZvcm5pYTERMA8GA1UEBwwIU3RhbmZvcmQxFDASBgNVBAoM',
      'C0lUIFNlcnZpY2VzMRkwFwYDVQQDDBBpZHAuc3RhbmZvcmQuZWR1MIIBIjANBgkq',
      'hkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAm6466Bd6mDwNOR2qZZy1WRZdjyrG2/xW',
      'amGEMekg38fyuoSCIiMcgeA9UIUbiRCpAN87yI9HPcgDEdrmCK3Ena3J2MdFZbRE',
      'b6fdRt76K+0FSl/CnyW9xaIlAhldXKbsgUDei3Xf/9P8H9Dxkk+PWd9Ha1RZ9Viz',
      'dOLe2S2iDKc1CJg2kdGQTuQu6mUEGrB9WJmrLHJS7GkGDqy96owFjRL/p0i9KBdR',
      'kgWG+GFHWkxzeNQ99yrQra3+C9FQXa/xLCdOY+BGOsAG7ej4094NZXRNTyXui4jR',
      'WCm2GVdIVl7YB9++XSntS7zQEJ9QBnC1D4bS0tljMfdOGAvdUuJY7QIDAQABo1Aw',
      'TjAdBgNVHQ4EFgQUJk4zcQ4JupEcAp0gEkob4YRDkckwHwYDVR0jBBgwFoAUJk4z',
      'cQ4JupEcAp0gEkob4YRDkckwDAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQUFAAOC',
      'AQEAKvf9AO4+osJZOmkv6AVhNPm6JKoBSm9dr9NhwpSS5fpro6PrIjDZDLh/L5d/',
      '+CQTDzuVsw3xwDtlm89lrzbqw5rSa2+ghJk79ijysSC0zOcD6ka9c17zauCNmFx9',
      'lj9iddUw3aYHQcQRktWL8pvI2WCY6lTU+ouNM+owStya7umZ9rBdjg/fQerzaQxF',
      'T0yV3tYEonL3hXMzSqZxWirwsyZ0TnhWJsgEnqqG9tCFAcFu2p+glwXn1WL2GCRv',
      'BfuJMPzg7ZB419AEoeYnLktqAWiU+ISnVfbwFOJ+OM/O7VQOeHDm2AeYcwo12CAc',
      '4GC9KWTs3QtS3GREPKYDlHRNxQ=='
    ].join(' '),
  }
}

SamlStrategy = require('passport-saml').Strategy
saml_config = {
  #path: '/saml/consume'
  path: '/Shibboleth.sso/SAML2/POST'
  loginPath: '/login'
  host: 'cs547check.herokuapp.com'
  decryptionPvk: getsecret('sp_key')
  decryptionCert: getsecret('sp_cert')
  protocol: 'https://'
  signatureAlgorithm: 'sha256'
  identifierFormat: 'urn:oasis:names:tc:SAML:2.0:nameid-format:transient'
  acceptedClockSkewMs: 500
  attributeConsumingServiceIndex: false
  disableRequestedAuthnContext: true
  forceAuthn: false
  skipRequestCompression: false
  validateInResponseTo: true
  entryPoint: idps['itlab'].entryPoint #'https://idp.itlab.stanford.edu/idp/shibboleth'
  cert: idps['itlab'].cert
  #entryPoint: idps['uat'].entryPoint #'https://idp.itlab.stanford.edu/idp/shibboleth'
  #cert: idps['uat'].cert
  #issuer: 'https://localhost:5000/login/callback'
  issuer: 'https://cs547check.herokuapp.com/' #'https://localhost:5000/saml/consume'
  #issuer: 'passport-saml'
  #protocol: 'http'
}
saml = new SamlStrategy(saml_config, (profile, done) ->
  done(null, profile)
)

passport.serializeUser (user, done) ->
  done(null, user)

passport.deserializeUser (user, done) ->
  done(null, user)

passport.use(saml)

kapp.use passport.initialize()
kapp.use passport.session()

#app.post '/login/callback', passport.authenticate('saml'), ->*
#  this.redirect '/hi'

#app.get '/login', passport.authenticate('saml'), ->*
#  this.redirect '/hi'

app.get '/hi', ->*
  this.body = 'hi'

app.post '/login', passport.authenticate('saml', {successRedirect: '/secret', failureRedirect: '/'})

app.get '/login', passport.authenticate('saml', {successRedirect: '/secret', failureRedirect: '/'})

#app.post '/saml/consume', passport.authenticate('saml', {successRedirect: '/secret', failureRedirect: '/'}), ->*
app.post '/Shibboleth.sso/SAML2/POST', passport.authenticate('saml'), ->*
  #this.redirect('/secret')
  if this.session
    url = this.session.authReturnUrl
    delete this.session.authReturnUrl
    this.redirect url
    return
  this.redirect '/secret'

#app.get '/saml/consume', passport.authenticate('saml', {successRedirect: '/secret', failureRedirect: '/'}), ->*
app.get '/Shibboleth.sso/SAML2/GET', passport.authenticate('saml'), ->*
  #this.redirect('/secret')
  if this.session
    url = this.session.authReturnUrl
    delete this.session.authReturnUrl
    this.redirect url
    return
  this.redirect '/secret'

app.get '/Shibboleth.sso/Metadata', ->*
  this.type = 'application/xml'
  this.status = 200
  this.body = saml.generateServiceProviderMetadata(getsecret('sp_cert'))
  # pass decryptionCert as argument
  # https://github.com/bergie/passport-saml/blob/master/lib/passport-saml/saml.js

app.get '/logout', ->*
  this.logout()
  this.redirect('/')

auth = (next) ->*
  if this.isAuthenticated()
    yield next
  else
    this.redirect('/login')

app.get '/secret', auth, ->*
  console.log this.req.user
  this.body = 'secret stuff'

*/


SUSamlStrategy = require('passport-stanford').Strategy
saml = new SUSamlStrategy({
  protocol: 'https://'
  idp: 'prod' #'itlabv2'
  #entityId: 'https://:5000/'
  entityId: 'https://cs547check.herokuapp.com/'
  loginPath: '/login'
  path: '/saml/consume'
  passReqToCallback: true
  passport: passport
  decryptionPvk: getsecret('sp_key')
  decryptionCert: getsecret('sp_cert')
  #acsPath: '/saml/consume'
  #entryPoint: 'https://idp.itlab.stanford.edu/idp/shibboleth'
  #issuer: 'passport-saml'
  host: 'cs547check.herokuapp.com'
})

passport.use(saml)

passport.serializeUser (user, done) ->
  done(null, user)

passport.deserializeUser (user, done) ->
  done(null, user)

app.post '/saml/consume', passport.authenticate(saml.name, {failureRedirect: '/', failureFlash: true}), ->*
  this.redirect '/'
  /*
  #this.redirect('/secret')
  console.log 'saml.name is'
  console.log saml.name
  console.log 'saml consume was called'
  if this.session
    console.log 'this.session is'
    console.log this.sesion
    url = this.session.authReturnUrl
    delete this.session.authReturnUrl
    this.redirect url
    return
  this.redirect '/secret'
  */

app.get '/login', passport.authenticate(saml.name, {successRedirect: '/', failureRedirect: '/login'})

/*
app.get '/login', passport.authenticate(saml.name), ->*
  console.log 'login was called'
  #this.redirect('/secret')
  if this.session
    console.log 'this.session is'
    console.log this.session
    url = this.session.authReturnUrl
    delete this.session.authReturnUrl
    this.redirect url
    return
  this.redirect '/secret'
*/

app.get '/metadata', ->*
  this.type = 'application/xml'
  this.status = 200
  this.body = saml.generateServiceProviderMetadata(getsecret('sp_cert'))
  # pass decryptionCert as argument
  # https://github.com/bergie/passport-saml/blob/master/lib/passport-saml/saml.js

auth = (next) ->*
  if this.isAuthenticated()
    yield next
  else
    this.redirect('/login')

app.get '/secret', auth, ->*
  console.log this.req.user
  console.log this.req.user.primary_email
  this.body = 'secret stuff'

/*
app.get '/login', passport.authenticate(saml.name, {successRedirect: '/', failureRedirect: '/login'}), ->*
  #this.body = 'login'
  #saml.return('/')
  this.redirect '/hi'
  #saml.return '/'

app.post '/login/callback', passport.authenticate(saml.name), ->*
  #this.body = 'saml consume'
  this.redirect '/hi'
  #saml.return '/'
*/

#app.get '/', ->*
#  #if this.isAuthenticated()
#  #  this.body = {'authenticated': true}
#  #  return
#  this.redirect '/login'
#  #this.body = 'hello world'

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

app.get '/attendance', auth, ->*
  {sunetid} = this.request.query
  if not sunetid?
    this.body = JSON.stringify []
    return
  seminars = yield get_seminars_attended_by_user sunetid
  this.body = JSON.stringify seminars

app.get '/pass_nopass', auth, ->*
  output = []
  all_users = yield list_all_users()
  for user in all_users
    seminars_attended = yield get_seminars_attended_by_user(user)
    passed = seminars_attended.length >= 9
    output.push "#{user}: #{passed}"
  this.body = output.join('\n')

app.get '/nopass', auth, ->*
  output = []
  all_users = yield list_all_users()
  for user in all_users
    seminars_attended = yield get_seminars_attended_by_user(user)
    passed = seminars_attended.length >= 9
    if not passed
      output.push "#{user}"
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

index_contents = fs.readFileSync 'www/index.html', 'utf-8'

serve_static = koa-static(__dirname + '/www')
for let filepath in glob.sync('www/**')
  fileroute = filepath.replace('www', '')
  if fileroute == ''
    return
  if fileroute == '/index.html'
    return
  app.get(fileroute, auth, serve_static)

app.get '/', auth, ->*
  email = this.req.user.primary_email ? this.req.user.email ? this.req.user.mail
  index_with_login = index_contents.replace('SOME_USERNAME_GOES_HERE', email)
  this.body = index_with_login

#kapp.use(app.routes())
#kapp.use(app.allowedMethods())
kapp.use app.middleware()
#kapp.use(koa-static(__dirname + '/www'))
port = process.env.PORT ? 5000

if on_heroku
  kapp.listen(port)
  console.log "on heroku, listening to port #{port} visit http://localhost:#{port}"
else
  #require('http').createServer(kapp.callback()).listen(5000, '0.0.0.0')
  selfSignedHttps(kapp.callback()).listen(5000, '0.0.0.0')
  console.log "running locally, listening to port #{port} visit https://localhost:#{port}"
