sinon = require "sinon"

time = Date.now()

{ TwerpTest } = require "twerp"
{ Client } = require "../lib/client"
{ V1, Api, Key } = require "../axle"

class AxleTest extends TwerpTest
  stubRespose: ( err, meta, results ) ->
    if process.env.NO_STUB
      return {}=
        restore: ( ) ->
        calledOnce: ( ) -> true

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

  "test updating an API": ( done ) ->
    api = new Api @axle, "facebook-#{ time }",
      endPoint: "graph.facebook.com"
      apiFormat: "json"

    stub = @stubRespose null, {}, apiFormat: "json"
    api.save ( err ) =>
      @ok not err
      @ok stub.calledOnce
      stub.restore()

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

        done 6

  "test finding an API": ( done ) ->
    stub = @stubRespose null, {}, endPoint: "graph.facebook.com"

    @axle.findApi "facebook-#{ time }", ( err, api ) =>
      @ok stub.calledOnce
      stub.restore()

      @ok not err

      @ok api
      @equal api.id, "facebook-#{ time }"
      @equal api.endPoint, "graph.facebook.com"

      done 5

  "test creating keys on an API": ( done ) ->
    key = new Key @axle, "hello-#{ time }",
      qps: 20
      qpd: 10

    stub = @stubRespose null, {}, { qps: 20, qpd: 10 }

    key.save ( err ) =>
      @ok not err
      @ok stub.calledOnce
      stub.restore()

      done 2
