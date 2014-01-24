sinon = require 'sinon'
_ = require 'underscore'
Backbone = require 'backbone'
Fetch = require '../lib/fetch'

class Collection extends Backbone.Collection

  _.extend @prototype, Fetch('foobar')

  url: 'foo/bar'

describe 'fetch until end mixin', ->

  beforeEach ->
    sinon.stub Backbone, 'sync'
    @collection = new Collection

  afterEach ->
    Backbone.sync.restore()

  describe '#fetchUntilEnd', ->

    it 'keeps fetching until the API returns no results', (done) ->
      @collection.fetchUntilEnd success: =>
        @collection.length.should.equal 3
        done()
      Backbone.sync.args[0][2].success [{ foo: 'bar' }]
      Backbone.sync.args[0][2].success [{ foo: 'bar' }]
      Backbone.sync.args[0][2].success [{ foo: 'bar' }]
      Backbone.sync.args[0][2].success []

describe 'fetch set items by key mixin', ->

  beforeEach ->
    sinon.stub Backbone, 'sync'
    @collection = new Collection

  afterEach ->
    Backbone.sync.restore()

  describe '#fetchSetItemsByKey', ->

    it "fetches the items for the first set by a key", (done) ->
      @collection.fetchSetItemsByKey 'foo:bar', success: =>
        @collection.first().get('name').should.equal 'FooBar'
        done()
      Backbone.sync.args[0][2].success [
        {
          id: _.uniqueId()
          key: 'homepage:featured'
          item_type: 'FeaturedLink'
          display_on_mobile: true
          display_on_desktop: true
        }
        {
          id: _.uniqueId()
          key: 'homepage:featured'
          item_type: 'FeaturedLink'
          display_on_mobile: true
          display_on_desktop: true
        }
      ]
      Backbone.sync.args[1][2].url.should.include 'set/7/items'
      Backbone.sync.args[1][2].success [{ name: 'FooBar' }]

    it 'returns an empty collection if there are no sets', (done) ->
      @collection.fetchSetItemsByKey 'foo:bar', success: =>
        @collection.models.length.should.equal 0
        done()
      Backbone.sync.args[0][2].success []