sinon = require "sinon"

{ TwerpTest } = require "twerp"

{ Client } = require "../lib/client"
{ V1, Api, Key } = require "../axle"

class AxleTest extends TwerpTest
  "setup stubs": ( done ) ->
    @_stubs ||= []
    done()

  stubRespose: ( err, meta, results ) ->
    return if process.env.NO_STUB

    stub = sinon.stub Client::, "request", ( path, options, cb ) ->
      return cb err, meta, results

    @_stubs.push stub

  "teardown restore stubs": ( done ) ->
    stub.restore() for stub in @_stubs
    done()

class exports.Basics extends AxleTest
  "test object creation": ( done ) ->
    @ok axle = new V1 "localhost", 3001

    done 1

class exports.ApiTest extends AxleTest
  "setup axle": ( done ) ->
    @axle = new V1 "localhost", 3001
    done()

  "test finding an API": ( done ) ->
    @stubRespose null, {}, endPoint: "graph.facebook.com"

    @axle.findApi "facebook", ( err, api ) =>
      @ok not err

      @ok api
      @equal api.id, "facebook"
      @equal api.endPoint, "graph.facebook.com"

      done 4

  "test updating an API": ( done ) ->
    api = new Api @axle, "facebook", { endPoint: "graph.facebook.com" }

    @stubRespose null, {},
      old:
        apiFormat: "json"
      new:
        apiFormat: "xml",

    api.update { apiFormat: "xml" }, ( err, results ) =>
      @ok not err

      @equal results.new.apiFormat, "xml"
      @equal results.old.apiFormat, "json"

      done 2
