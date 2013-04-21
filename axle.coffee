# A wrapper library for interfacing with the API Axle API
_ = require "lodash"
request = require "request"
qs = require "querystring"

class Client
  constructor: ( @host, @port ) ->

  getPath: ( path, query_params ) ->
    url = "http://#{ @host }:#{ @port }#{ path }"
    if query_params
      url += "?#{ qs.stringify query_params }"

    return url

  request: ( path, options, cb ) ->
    options = _.merge options,
      json: true
      method: "GET"
      headers:
        "content-type": "application/json"

    options.url = @getPath( path, options.query_params )

    request options, ( err, res ) =>
      return cb err if err

      { meta, results } = res.body

      if not meta
        return cb new Error res.body

      if res.statusCode isnt 200
        { type, message } = results.error
        problem = new Error message
        problem.type = type
        return cb problem, meta, null

      return cb null, meta, results

class exports.V1 extends Client
  getKeysByApi: ( api, options={}, cb ) ->
    @request "/v1/api/#{api}/keys", { query_params: options }, cb

  getApis: ( options={}, cb ) ->
    @request "/v1/apis", { query_params: options }, cb

  getKey: ( key, cb ) ->
    @request "/v1/key/#{key}", { query_params: options }, cb

  getKeyStats: ( key, options={}, cb ) ->
    @request "/v1/key/#{key}/stats", { query_params: options }, cb

  getApiStats: ( api, options={}, cb ) ->
    @request "/v1/api/#{api}/stats", { query_params: options }, cb
