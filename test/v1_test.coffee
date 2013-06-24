sinon = require "sinon"

time = Date.now()

{ TwerpTest } = require "twerp"
{ Client } = require "../lib/client"
{ AxleObject, V1, Api, Key } = require "../axle"

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

  "test getRangeOptions": ( done ) ->
    @ok axle = new V1 "localhost", 3001
    @ok ao = new AxleObject()

    expectants = [
      [ [ 1, 2, ( ) -> yes ], { from: 1, to: 2, resolve: true }  ]
      [ [ 23, ( ) -> yes ],   { from: 0, to: 23, resolve: true } ]
      [ [ ( ) -> yes ],       { from: 0, to: 20, resolve: true } ]
    ]

    for e in expectants
      res = ao.getRangeOptions e[0]

      @equal res.length, 2
      [ options, func ] = res

      # correct options result
      @deepEqual e[1], options.query_params

      # check the func was correct
      has_run = func()
      @equal has_run, true, "Function has_run"

    done 11

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

      api.update { apiFormat: "xml" }, ( err, meta, results ) =>
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
      qps: 2
      qpd: 10

    stub = @stubRespose null, {}, { qps: 20, qpd: 10 }

    key.save ( err ) =>
      @ok not err
      @ok stub.calledOnce
      stub.restore()

      done 2

  "test linking keys to an API": ( done ) ->
    api = new Api @axle, "facebook-#{ time }",
      endPoint: "graph.facebook.com"

    stub = @stubRespose null, {}, { qps: 2, qpd: 10 }
    api.linkKey "hello-#{ time }", ( err, key ) =>
      @ok not err
      @ok stub.calledOnce
      stub.restore()

      @ok key

      @equal key.id, "hello-#{ time }"
      @equal key.qps, 2
      @equal key.qpd, 10

      done 6

  "test listing keys": ( done ) ->
    api = new Api @axle, "facebook-#{ time }",
      endPoint: "graph.facebook.com"

    # save another key
    key = new Key @axle, "hello2-#{ time }",
      qps: 20
      qpd: 10

    # save another key
    stub = @stubRespose null, {}, { qps: 20, qpd: 10 }
    key.save ( err ) =>
      @ok not err
      @ok stub.calledOnce
      stub.restore()

      # link it to facebook
      stub = @stubRespose null, {}, {}
      api.linkKey "hello2-#{ time }", ( err, key ) =>
        @ok not err
        @ok stub.calledOnce
        stub.restore()

        res = {}
        res["hello2-#{ time }"] = { qpd: 10, qps: 20 }
        res["hello-#{ time }"] = { qpd: 172800, qps: 2 }

        stub = @stubRespose null, {}, res

        api.keys ( err, [ key1, key2 ] ) =>
          @ok not err
          @ok stub.calledOnce
          stub.restore()

          @equal key1.id, "hello2-#{ time }"
          @equal key1.qps, 20

          @equal key2.id, "hello-#{ time }"
          @equal key2.qps, 2

          done 10
