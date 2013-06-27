# NodeAxle

A client library for the ApiAxle API. Written in Coffeescript but
distrubuted as JS.

# Example Usage

## Initialisation

    { V1 } = require "apiaxle-api-client"
    v1 = new V1 "127.0.0.1", 3000

## Creating new things

    v1.newApi "acme", { endPoint: "example.com" }, ( err, meta, api ) ->
      api.save ( err ) ->
        console.log "Created #{ api.id }"
      
    v1.newKey "phil", { qps: 1, qpd: 2 }, ( err, meta, key ) ->
      key.save ( err ) ->
        console.log "Created #{ key.id }"

    v1.newKeyring "keyholder", {}, ( err, meta, keyring ) ->
      keyring.save ( err ) ->
        console.log "Created #{ keyring.id }"

## Finding things

    v1.findApi "acme", ( err, meta, api ) ->
      console.log "Api acme has endpoint #{ api.endPoint }"

    v1.findKey "phil", ( err, meta, key ) ->
      console.log "Key phil has qps #{ key.qps }"

    v1.findKeyring "phil", ( err, meta, keyring ) ->
      console.log "Keyring phil has qps #{ keyring.qps }"

## Linking keys to APIs (or keyrings)

    v1.findApi "acme", ( err, meta, api ) ->
      api.linkKey "phil", ( err, meta, key ) ->
        console.log "Linked #{ key.id }"

If you don't want the cost of finding the API, just do this:

    api = v1.newApi "acme", {}
    api.linkKey "phil", ( err, meta, key ) ->
      console.log "Linked #{ key.id }"

## Deleting things

    api.delete ( err ) -> console.log "Deleted"

## Updating things

    # be sure to discard `api` once you've done this. newApi is now
    # populated with the correct details
    api.update { apiFormat: "XML" }, ( err, meta, newApi ) ->
      console.log "Updated with a new Api object"
