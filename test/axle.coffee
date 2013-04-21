sinon = require "sinon"

{ TwerpTest } = require "twerp"
{ V1 } = require "../axle"

class exports.AxleTest extends TwerpTest
  "test object creation": ( done ) ->
    @ok axle = new V1 "localhost", 3001

    done 1
