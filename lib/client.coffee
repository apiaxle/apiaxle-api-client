_ = require "lodash"
request = require "request"
qs = require "querystring"

{ EventEmitter } = require "events"

class exports.Client
  constructor: ( @host ) ->
    @emitter = new EventEmitter()

  getPath: ( path, query_params ) ->
    url = "http://#{ @host }#{ path }"
    if query_params
      url += "?#{ qs.stringify query_params }"

    return url

  on: ( ) ->
    @emitter.on arguments...

  request: ( path, options, cb ) ->
    defaults =
      json: true
      method: "GET"
      headers:
        "content-type": "application/json"

    options = _.merge defaults, options

    options.url = @getPath path, options.query_params
    @emitter.emit "request", options

    request options, ( err, res ) =>
      return cb err if err

      # the response contains meta and the actual results
      { meta, results } = res.body
      return cb new Error res.body if not meta

      if res.statusCode isnt 200
        { type, message } = results.error
        problem = new Error message
        problem.type = type
        return cb problem, meta, null

      return cb null, meta, results
