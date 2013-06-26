_ = require "lodash"
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

  "test #getRangeOptions": ( done ) ->
    @ok axle = new V1 "localhost", 3001

    res = axle.getRangeOptions { query_params: { from: 3 } }

    @equal res.query_params.from, 3
    @equal res.query_params.to, 20
    @equal res.query_params.resolve, true

    done 4

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

    @axle.findApi "facebook-#{ time }", ( err, meta, api ) =>
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
    api.linkKey "hello-#{ time }", ( err, meta, key ) =>
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

        api.keys {}, ( err, meta, [ key1, key2 ] ) =>
          @ok not err
          @ok stub.calledOnce
          stub.restore()

          @equal key1.id, "hello2-#{ time }"
          @equal key1.qps, 20

          @equal key2.id, "hello-#{ time }"
          @equal key2.qps, 2

          done 10

  "test all apis": ( done ) ->
    # save another api
    api = new Api @axle, "superduper3-#{ time }",
      qps: 20
      qpd: 10

    # save another api
    stub = @stubRespose null, {}, { qps: 20, qpd: 10 }
    api.save ( err ) =>
      @ok not err
      @ok stub.calledOnce
      stub.restore()

      data = {}
      data["superduper1"] = { qps: 20, qpd: 10 }
      data["superduper2"] = { qps: 10, qpd: 10 }
      data["superduper3"] = { qps: 20, qpd: 1 }

      # link it to facebook
      stub = @stubRespose null, {}, data

      @axle.apis {}, ( err, meta, [ superduper1, superduper2, superduper3 ] ) =>
        @ok not err
        @ok stub.calledOnce
        stub.restore()

        @deepEqual superduper1.data, { qps: 20, qpd: 10 }
        @ok superduper1.client

        @deepEqual superduper2.data, { qps: 10, qpd: 10 }
        @ok superduper2.client

        @deepEqual superduper3.data, { qps: 20, qpd: 1 }
        @ok superduper3.client

        done 10

  "test all keys": ( done ) ->
    # save another key
    key = new Key @axle, "hello3-#{ time }",
      qps: 20
      qpd: 10

    # save another key
    stub = @stubRespose null, {}, { qps: 20, qpd: 10 }
    key.save ( err ) =>
      @ok not err
      @ok stub.calledOnce
      stub.restore()

      data = {}
      data["hello1"] = { qps: 20, qpd: 10 }
      data["hello2"] = { qps: 10, qpd: 10 }
      data["hello3"] = { qps: 20, qpd: 1 }

      # link it to facebook
      stub = @stubRespose null, {}, data

      @axle.keys {}, ( err, meta, [ hello1, hello2, hello3 ] ) =>
        @ok not err
        @ok stub.calledOnce
        stub.restore()

        @deepEqual hello1.data, { qps: 20, qpd: 10 }
        @ok hello1.client

        @deepEqual hello2.data, { qps: 10, qpd: 10 }
        @ok hello2.client

        @deepEqual hello3.data, { qps: 20, qpd: 1 }
        @ok hello3.client

        done 10
