sinon = require "sinon"

{ TwerpTest } = require "twerp"

{ Client } = require "../lib/client"
{ V1 } = require "../axle"

class exports.AxleTest extends TwerpTest
  stubRespose: ( err, meta, results ) ->
    return if process.env.NO_STUB

    sinon.stub Client::, "request", ( path, options, cb ) ->
      return cb err, meta, results

  "test object creation": ( done ) ->
    @ok axle = new V1 "localhost", 3001

    done 1

  "test finding an API": ( done ) ->
    @ok axle = new V1 "localhost", 3001

    @stubRespose null, {},
      endPoint: "graph.facebook.com"

    axle.findApi "facebook", ( err, api ) =>
      @isNull err

      @ok api
      @equal api.id, "facebook"
      @equal api.endPoint, "graph.facebook.com"

      done 5
