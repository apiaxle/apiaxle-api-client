# always run as test
process.env.NODE_ENV = "test"

{ ApiaxleApi } = require "../apiaxle_api"
{ AppTest } = require "apiaxle.base"

class exports.ApiaxleTest extends AppTest
  @appClass = ApiaxleApi
