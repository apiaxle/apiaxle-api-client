{ V1 } = require "../index"
should = require "should"

describe "The Client", ->
  v1 = null

  before ->
    v1 = new V1( process.env.APIAXLE_API_LOCATION or "http://localhost:3000" )

  it "should have a valid client", ( done ) ->
    v1.should.be.ok
    done()

  it "can ping the API", ( done ) ->
    v1.ping ( err, res ) ->
      return done err if err
      res.body.should.equal "pong"

      done()

  it "can fetch keys", ( done ) ->
    v1.keys {}, ( err, meta, keys ) ->
      return done err if err
      keys.should.be.ok
      done()

  it "can fetch the model documentation", ( done ) ->
    v1.modelDocs ( err, meta, docs ) ->
      return done err if err
      docs.should.be.ok
      docs.keyfactory.should.be.ok
      docs.keyfactory.properties.disabled.type.should.equal "boolean"
      done()
