_ = require "lodash"
{ Client } = require "./lib/client"

class exports.AxleObject
  constructor: ( @client, @id, @data ) -> _.extend this, @data

  request: ( args... ) -> @client.request args...

  save: ( cb ) ->
    options =
      method: "POST"
      body: JSON.stringify( @data )

    return @request @url(), options, ( err, meta, results ) ->
      # repopulate the data for this item
      @data = results
      _.extend this, @data

      return cb err if err
      return cb null, meta, results

  update: ( new_details, cb ) ->
    options =
      method: "PUT"
      body: JSON.stringify( new_details )

    @request @url(), options, ( err, meta, details ) =>
      return cb err if err

      new_thing = details.new
      old_thing = details.old

      # repopulate the data for this item
      @data = new_thing
      _.extend this, @data

      return cb null, meta, details

  stats: ( options, cb ) ->
    return @request "#{ @url() }/stats", options, cb

  delete: ( new_details, cb ) ->
    options =
      method: "DELETE"
      body: JSON.stringify( new_details )

    return @request @url(), options, cb

class KeyHolder extends exports.AxleObject
  linkKey: ( key_id, cb ) ->
    options =
      method: "PUT"
      body: {}

    @request "#{ @url() }/linkkey/#{ key_id }", options, ( err, meta, res ) =>
      return cb err if err
      return cb null, meta, @client.newKey( key_id, res )

  unlinkKey: ( key_id, cb ) ->
    options =
      method: "PUT"
      body: {}

    @request "#{ @url() }/unlinkkey/#{ key_id }", options, ( err, meta, res ) =>
      return cb err if err
      return cb null, meta, @client.newKey( key_id, res )

  keys: ( options, cb ) ->
    options = @client.getRangeOptions options

    @request "#{ @url() }/keys", options, ( err, meta, results ) =>
      return cb err if err

      instanciated = for id, details of results
        @client.newKey id, details

      return cb null, meta, instanciated

class exports.Key extends exports.AxleObject
  url: -> "/key/#{ @id }"

  linkedApis: ( options, cb ) ->
    default_options =
      query_params:
        resolve: true

    options = _.merge default_options, options

    @request "#{ @url() }/apis", options, ( err, meta, results ) =>
      return cb err if err

      instanciated = for id, details of results
        @client.newApi id, details

      return cb null, meta, instanciated

  charts: ( options, cb ) ->
    @request "#{ @url() }/apicharts", options, cb

class exports.Api extends KeyHolder
  url: -> "/api/#{ @id }"

  charts: ( options, cb ) ->
    @request "#{ @url() }/keycharts", options, cb

  statsTimers: ( options, cb ) ->
    return @request "#{ @url() }/stats/timers", options, cb

class exports.Keyring extends KeyHolder
  url: -> "/keyring/#{ @id }"

class exports.V1 extends Client
  constructor: ( args... ) ->
    # quick access to these things without having to initialise a new
    # client e.g. newApi( "blah", {} )
    for type in [ "Api", "Key", "Keyring" ]
      do( type ) =>
        this["new#{ type }"] = ( id, data ) =>
          return new exports[type]( this, id, data )

    super args...

  getRangeOptions: ( options ) ->
    default_options =
      query_params:
        resolve: true
        from: 0
        to: 20

    return _.merge default_options, { query_params: options }

  request: ( path, options, cb ) ->
    super "/v1#{ path }", options, cb

  apis: ( options, cb ) ->
    options = @getRangeOptions options

    @request "/apis", options, ( err, meta, results ) =>
      return cb err if err

      instanciated = for id, details of results
        @newApi id, details

      return cb null, meta, instanciated

  keys: ( options, cb ) ->
    options = @getRangeOptions options

    @request "/keys", options, ( err, meta, results ) =>
      return cb err if err

      instanciated = for id, details of results
        @newKey id, details

      return cb null, meta, instanciated

  keyrings: ( options, cb ) ->
    options = @getRangeOptions options

    @request "/keyrings", options, ( err, meta, results ) =>
      return cb err if err

      instanciated = for id, details of results
        @newKey id, details

      return cb null, meta, instanciated

  findKey: ( name, cb ) ->
    @request "/key/#{ name }", {}, ( err, meta, details ) =>
      return cb err if err
      return cb null, meta, @newKey( name, details )

  findApi: ( name, cb ) ->
    @request "/api/#{ name }", {}, ( err, meta, details ) =>
      return cb err if err
      return cb null, meta, @newApi( name, details )
