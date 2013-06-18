sinon = require "sinon"

{ TwerpTest } = require "twerp"

{ Client } = require "../lib/client"
{ V1 } = require "../axle"

class exports.AxleTest extends TwerpTest
  stubRespose: ( err, meta, results ) ->
    sinon.stub Client::, "request", ( path, options, cb ) ->
      return cb err, meta, results

  "test object creation": ( done ) ->
    @ok axle = new V1 "localhost", 3001

    done 1

  "test finding an API": ( done ) ->
    @ok axle = new V1 "localhost", 3001

    @stubRespose null, {},
      endPoint: "graph.facebook.com"

    axle.findApi "hello", ( err, api ) =>
      @isNull err

      @ok api
      @equal api.id, "hello"
      @equal api.endPoint, "graph.facebook.com"

      done 5
