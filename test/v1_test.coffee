sinon = require "sinon"

{ TwerpTest } = require "twerp"

{ Client } = require "../lib/client"
{ V1, Api, Key } = require "../axle"

class AxleTest extends TwerpTest
  stubRespose: ( err, meta, results ) ->
    fakestub =
      restore: ( ) ->

    return fakestub if process.env.NO_STUB

    return sinon.stub Client::, "request", ( path, options, cb ) ->
      return cb err, meta, results

class exports.Basics extends AxleTest
  "test object creation": ( done ) ->
    @ok axle = new V1 "localhost", 3001

    done 1

class exports.ApiTest extends AxleTest
  "setup axle": ( done ) ->
    @axle = new V1 "localhost", 3001
    done()

  "test finding an API": ( done ) ->
    stub = @stubRespose null, {}, endPoint: "graph.facebook.com"

    @axle.findApi "facebook", ( err, api ) =>
      @ok stub.calledOnce
      stub.restore()

      @ok not err

      @ok api
      @equal api.id, "facebook"
      @equal api.endPoint, "graph.facebook.com"

      done 5

  "test updating an API": ( done ) ->
    api = new Api @axle, "facebook",
      endPoint: "graph.facebook.com"

    stub = @stubRespose null, {},
      old:
        apiFormat: "json"
      new:
        apiFormat: "xml",

    api.update { apiFormat: "xml" }, ( err, results ) =>
      @ok not err

      @ok stub.calledOnce
      stub.restore()

      @equal results.new.apiFormat, "xml"
      @equal results.old.apiFormat, "json"

      done 4
