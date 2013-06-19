_ = require "lodash"
{ Client } = require "./lib/client"

class AxleObject extends Client
  constructor: ( @client, @id, @data ) ->
    _.extend this, @data

  request: ( args... ) -> @client.request args...

  save: ( cb ) ->
    options =
      method: "POST"
      body: JSON.stringify( @data )

    return @request @url(), options, ( err, meta, results ) ->
      return cb err if err
      return cb null, results

  update: ( new_details, cb ) ->
    options =
      method: "PUT"
      body: JSON.stringify( new_details )

    return @request @url(), options, ( err, meta, results ) ->
      return cb err if err
      return cb null, results

class KeyHolder extends AxleObject

class Key extends AxleObject
  url: -> "/key/#{ @id }"

class Api extends KeyHolder
  url: -> "/api/#{ @id }"

  linkkey: ( key_id, cb ) ->
    options =
      method: "PUT"
      body: {}

    @request "#{ @url() }/linkkey/#{ key_id }", options, ( err, meta, res ) =>
      return cb err if err
      return cb null, new Key @client, key_id, res

  # keys: ->
  #   @request "/keys", { resolve: true }, ( err, meta, results ) ->
  #     return cb err if err
  #     return for id, details of results
  #       new Key( @axle, name, details )

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