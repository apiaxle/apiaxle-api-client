_ = require "lodash"
request = require "request"
qs = require "querystring"

{ EventEmitter } = require "events"

class exports.Client
  constructor: ( @url ) ->
    @emitter = new EventEmitter()

  getPath: ( path, query_params ) ->
    url = "#{ @url }#{ path }"
    if query_params
      url += "?#{ qs.stringify query_params }"

    return url

  on: ( ) ->
    @emitter.on arguments...

  rawRequest: ( path, options, cb ) ->
    options.url = @getPath path, options.query_params
    @emitter.emit "request", options

    request options, ( err, res ) =>
      return cb err if err
      return cb null, res.body

  request: ( path, options, cb ) ->
    defaults =
      json: true
      method: "GET"
      headers:
        "content-type": "application/json"

    options = _.merge defaults, options

    @rawRequest options, ( err, res ) =>
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
