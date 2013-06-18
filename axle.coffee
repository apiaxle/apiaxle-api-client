_ = require "lodash"
{ Client } = require "./lib/client"

class ApiAxleObject extends Client
  constructor: ( @client, @id, data ) ->
    _.extend this, data

  update: ( new_details, cb ) ->
    options =
      method: "PUT"
      body: JSON.stringify( new_details )

    return @client.request @url(), options, ( err, meta, results ) ->
      return cb err if err
      return cb null, results

class Key extends ApiAxleObject
  url: -> "/key/#{ @id }"

class Api extends ApiAxleObject
  url: -> "/api/#{ @id }"

class V1 extends Client
  request: ( path, options, cb ) ->
    super "/v1#{ path }", options, cb

  findKey: ( name, cb ) ->
    @request "/key/#{ name }", {}, ( err, meta, details ) =>
      return cb err if err
      return cb null, new Key( this, name, details )

  findApi: ( name, cb ) ->
    @request "/api/#{ name }", {}, ( err, meta, details ) =>
      return cb err if err
      return cb null, new Api( this, name, details )

module.exports =
  Api: Api
  Key: Key
  V1: V1