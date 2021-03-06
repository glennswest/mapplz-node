assert = require('chai').assert
MongoClient = require('mongodb').MongoClient

MapPLZ = require '../lib/mapplz'
mapstore = new MapPLZ.MapPLZ
collected = null

connect = (callback) ->
  if collected
    collected.remove {}, (err) ->
      if err
        console.error 'collection clear error'
        assert.equal(err, null)
      else
        callback()
    return

  MongoClient.connect "mongodb://localhost:27017/sample", (err, db) ->
    if err
      console.error 'error connecting to MongoDB'
      assert.equal(err, null)
    else
      db.collection 'mapplz', (err, collection) ->
        if err
          console.error 'collection error'
          assert.equal(err, null)
        else
          collection.remove {}, (err) ->
            if err
              console.error 'collection clear error'
              assert.equal(err, null)

            collection.ensureIndex { geo: "2dsphere" }, (err) ->
              if err
                console.error 'index error'
                assert.equal(err, null)

              mapstore.database = new MapPLZ.MongoDB collection
              collected = collection
              callback()

describe 'queries db', ->
  it 'returns count', (done) ->
    connect ->
      assert.equal(mapstore.database == null, false)
      mapstore.add([0, 1], (err, pt) ->
        mapstore.add([2, 3, 'hello world'], (err, pt2) ->
          mapstore.add({ lat: 4, lng: 5, label: 'hello world' }, (err, pt3) ->
            mapstore.add({ path: [[5, 10], [15, 20]], label: 'hello world' }, (err, line) ->
              assert.equal(line.toWKT(), 'LINESTRING(10 5, 20 15)')
              mapstore.count("", (err, count) ->
                assert.equal(count, 4)
                done()
              )
            )
          )
        )
      )

  it 'deletes a point', (done) ->
    connect ->
      mapstore.add(40, -70, (err, pt) ->
        pt.delete ->
          mapstore.count(null, (err, count) ->
            assert.equal(err, null)
            assert.equal(count, 0)
            done()
          )
      )

  it 'queries by property', (done) ->
    connect ->
      assert.equal(mapstore.database == null, false)
      mapstore.add({ lat: 2, lng: 3, color: 'blue' }, (err, pt) ->
        mapstore.add({ lat: 2, lng: 3, color: 'red' }, (err, pt2) ->
          mapstore.query({ color: "blue" }, (err, results) ->
            assert.equal(results.length, 1)
            assert.equal(results[0].properties.color, "blue")
            done()
          )
        )
      )

  it 'counts by property', (done) ->
    connect ->
      assert.equal(mapstore.database == null, false)
      mapstore.add({ lat: 2, lng: 3, color: 'blue' }, (err, pt) ->
        mapstore.add({ lat: 2, lng: 3, color: 'red' }, (err, pt2) ->
          mapstore.count({ color: "blue" }, (err, count) ->
            assert.equal(count, 1)
            done()
          )
        )
      )

  it 'finds nearest point', (done) ->
    connect ->
      mapstore.add { lat: 40, lng: -70 }, (err, pt) ->
        mapstore.add { lat: 35, lng: 110 }, (err, pt2) ->
          mapstore.near [30, -60], 1, (err, nearest) ->
            assert.equal(nearest.length, 1)
            response = nearest[0]
            assert.equal(response.lat, 40)
            assert.equal(response.lng, -70)
            done()

  it 'finds point in polygon', (done) ->
    connect ->
      mapstore.add { lat: 40, lng: -70 }, (err, pt) ->
        mapstore.add { lat: 35, lng: 110 }, (err, pt2) ->
          mapstore.inside [[[38, -72], [38, -68], [42, -68], [42, -72], [38, -72]]], (err, within) ->
            assert.equal(within.length, 1)
            response = within[0]
            assert.equal(response.lat, 40)
            assert.equal(response.lng, -70)
            done()

describe 'saves to db', ->
  it 'saves properties to db', (done) ->
    connect ->
      assert.equal(mapstore.database == null, false)
      mapstore.add({ lat: 2, lng: 3, label: 'hello world' }, (err, pt) ->
        mapstore.query("", (err, results) ->
          firstpt = results[0]
          assert.equal(firstpt.lat, 2)
          assert.equal(firstpt.lng, 3)
          assert.equal(firstpt.type, 'point')
          assert.equal(firstpt.properties.label, 'hello world')
          done()
        )
      )

  it 'updates properties in db', (done) ->
    connect ->
      assert.equal(mapstore.database == null, false)
      mapstore.add({ lat: 2, lng: 3, label: 'hello' }, (err, pt) ->
        pt.properties.label = 'world'
        pt.save (err, ptnew) ->
          mapstore.query("", (err, results) ->
            assert.equal(results.length, 1)
            assert.equal(results[0].properties.label, 'world')
            done()
          )
      )

  it 'updates locations in db', (done) ->
    connect ->
      assert.equal(mapstore.database == null, false)
      mapstore.add({ lat: 2, lng: 3 }, (err, pt) ->
        pt.lat = 5
        pt.save (err, ptnew) ->
          mapstore.query("", (err, results) ->
            assert.equal(results.length, 1)
            assert.equal(results[0].lat, 5)
            done()
          )
      )
