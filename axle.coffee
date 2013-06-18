_ = require "lodash"
{ Client } = require "./lib/client"

class ApiAxleObject
  constructor: ( @id, data ) ->
    _.extend this, data

class Key extends ApiAxleObject
class Api extends ApiAxleObject

class exports.V1 extends Client
  request: ( path, options, cb ) ->
    super "/v1#{ path }", options, cb

  findApi: ( name, cb ) ->
    @request "/api/#{ name }", {}, ( err, meta, details ) ->
      return cb err if err
      return cb null, new Api( name, details )
