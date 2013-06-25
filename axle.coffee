_ = require "lodash"
{ Client } = require "./lib/client"

class AxleObject
  constructor: ( @client, @id, @data ) ->
    _.extend this, @data

  request: ( args... ) -> @client.request args...

  getRangeOptions: ( args ) ->
    from = 0
    to = 20
    cb = null

    switch args.length
      when 3 then [ from, to, cb ] = args
      when 2 then [ to, cb ] = args
      when 1 then [ cb ] = args

    options =
      query_params:
        resolve: true
        from: from
        to: to

    return [ options, cb ]

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

    return @request @url(), options, cb

  delete: ( new_details, cb ) ->
    options =
      method: "DELETE"
      body: JSON.stringify( new_details )

    return @request @url(), options, cb

class KeyHolder extends AxleObject
  linkKey: ( key_id, cb ) ->
    options =
      method: "PUT"
      body: {}

    @request "#{ @url() }/linkkey/#{ key_id }", options, ( err, meta, res ) =>
      return cb err if err
      return cb null, new Key @client, key_id, res

  unlinkKey: ( key_id, cb ) ->
    options =
      method: "PUT"
      body: {}

    @request "#{ @url() }/unlinkkey/#{ key_id }", options, ( err, meta, res ) =>
      return cb err if err
      return cb null, new Key @client, key_id, res

  keys: ( ) ->
    [ options, cb ] = @getRangeOptions arguments

    @request "#{ @url() }/keys", options, ( err, meta, results ) =>
      return cb err if err

      instanciated = for id, details of results
        new Key( @client, id, details )

      return cb null, instanciated

class Key extends AxleObject
  url: -> "/key/#{ @id }"

class Api extends KeyHolder
  url: -> "/api/#{ @id }"

class Keyring extends KeyHolder
  url: -> "/keyring/#{ @id }"

class V1 extends Client
  request: ( path, options, cb ) ->
    super "/v1#{ path }", options, cb

  keys: ( ) ->
    [ options, cb ] = @getRangeOptions arguments

    @request "#{ @url() }/keys", options, ( err, meta, results ) =>
      return cb err if err

      instanciated = for id, details of results
        new Key( @client, id, details )

      return cb null, instanciated

  apis: ( ) ->
    [ options, cb ] = @getRangeOptions arguments

    @request "#{ @url() }/apis", options, ( err, meta, results ) =>
      return cb err if err

      instanciated = for id, details of results
        new Api( @client, id, details )

      return cb null, instanciated

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
  Keyring: Keyring
  V1: V1
  AxleObject: AxleObject
