assert = require('chai').assert

MapPLZ = require('../lib/mapplz')
mapstore = new MapPLZ

describe('add point', ->
  it('uses params: lat, lng', (done) ->
    mapstore.add(40, -70, (err, pt) ->
      assert.equal(pt.lat, 40)
      assert.equal(pt.lng, -70)
      done()
    )
  )

  it('uses params: lat, lng, key_property', (done) ->
    mapstore.add(40, -70, 'key', (err, pt) ->
      assert.equal(pt.lat, 40)
      assert.equal(pt.lng, -70)
      assert.equal(pt.properties.property, 'key')
      done()
    )
  )

  it('uses params: lat, lng, properties', (done) ->
    mapstore.add(40, -70, { hello: 'world' }, (err, pt) ->
      assert.equal(pt.lat, 40)
      assert.equal(pt.lng, -70)
      assert.equal(pt.properties.hello, 'world')
      done()
    )
  )

  it('uses params: [lat, lng]', (done) ->
    mapstore.add([40, -70], (err, pt) ->
      assert.equal(pt.lat, 40)
      assert.equal(pt.lng, -70)
      done()
    )
  )

  it('uses params: [lat, lng, key_property]', (done) ->
    mapstore.add([40, -70, 'key'], (err, pt) ->
      assert.equal(pt.lat, 40)
      assert.equal(pt.lng, -70)
      assert.equal(pt.properties.property, 'key')
      done()
    )
  )

  it('uses params: [lat, lng, properties]', (done) ->
    mapstore.add([40, -70, { hello: 'world' }], (err, pt) ->
      assert.equal(pt.lat, 40)
      assert.equal(pt.lng, -70)
      assert.equal(pt.properties.hello, 'world')
      done()
    )
  )

  it('uses params: { lat: 40, lng: -70 }', (done) ->
    mapstore.add({ lat: 40, lng: -70}, (err, pt) ->
      assert.equal(pt.lat, 40)
      assert.equal(pt.lng, -70)

      mapstore.add({ lat: 40, lng: -70, color: "#f00" }, (err, pt) ->
        assert.equal(pt.properties.color, "#f00")
        done()
      )
    )
  )

  it('uses JSON string: { "lat": 40, "lng": -70 }', (done) ->
    mapstore.add('{ "lat": 40, "lng": -70}', (err, pt) ->
      assert.equal(pt.lat, 40)
      assert.equal(pt.lng, -70)
      done()
    )
  )
)

describe('add line', ->
  it('uses params: [[lat1, lng1], [lat2, lng2]]', (done) ->
    mapstore.add([[40, -70], [22, -110]], (err, line) ->
      assert.equal(line.type, 'line')
      first_pt = line.path[0]
      assert.equal(first_pt[0], 40)
      assert.equal(first_pt[1], -70)
      done()
    )
  )

  it('uses params: { path: [[lat1, lng1], [lat2, lng2]] }', (done) ->
    mapstore.add({ path: [[40, -70], [22, -110]] }, (err, line) ->
      assert.equal(line.type, 'line')
      first_pt = line.path[0]
      assert.equal(first_pt[0], 40)
      assert.equal(first_pt[1], -70)
      done()
    )
  )

  it('adds properties: { path: [pt1, pt], key: "x" }', (done) ->
    mapstore.add({ path: [[40, -70], [22, -110]], key: "x" }, (err, line) ->
      assert.equal(line.type, 'line')
      first_pt = line.path[0]
      assert.equal(first_pt[0], 40)
      assert.equal(first_pt[1], -70)
      assert.equal(line.properties.key, "x")
      done()
    )
  )

  it('uses JSON string: { path: [[lat1, lng1], [lat2, lng2]] }', (done) ->
    mapstore.add('{ "path": [[40, -70], [22, -110]] }', (err, line) ->
      assert.equal(line.type, 'line')
      first_pt = line.path[0]
      assert.equal(first_pt[0], 40)
      assert.equal(first_pt[1], -70)
      done()
    )
  )
)

describe('add polygon', ->
  it('uses params: [[[lat1, lng1], [lat2, lng2], [lat3, lng3], [lat1, lng1]]]', (done) ->
    mapstore.add([[[40, -70], [22, -110], [40, -110], [40, -70]]], (err, poly) ->
      assert.equal(poly.type, 'polygon')
      first_pt = poly.path[0][0]
      assert.equal(first_pt[0], 40)
      assert.equal(first_pt[1], -70)
      done()
    )
  )

  it('uses params: { path: [[[lat1, lng1], [lat2, lng2], [lat3, lng3], [lat1, lng1]]] }', (done) ->
    mapstore.add({ path: [[[40, -70], [22, -110], [40, -110], [40, -70]]]}, (err, poly) ->
      assert.equal(poly.type, 'polygon')
      first_pt = poly.path[0][0]
      assert.equal(first_pt[0], 40)
      assert.equal(first_pt[1], -70)
      done()
    )
  )

  it('uses params to add properties', (done) ->
    mapstore.add({ path: [[[40, -70], [22, -110], [40, -110], [40, -70]]], key: "x" }, (err, poly) ->
      assert.equal(poly.type, 'polygon')
      first_pt = poly.path[0][0]
      assert.equal(first_pt[0], 40)
      assert.equal(first_pt[1], -70)
      assert.equal(poly.properties.key, "x")
      done()
    )
  )

  it('uses JSON string: { path: [[[lat1, lng1], [lat2, lng2], [lat3, lng3], [lat1, lng1]]] }', (done) ->
    mapstore.add('{"path": [[[40, -70], [22, -110], [40, -110], [40, -70]]]}', (err, poly) ->
      assert.equal(poly.type, 'polygon')
      first_pt = poly.path[0][0]
      assert.equal(first_pt[0], 40)
      assert.equal(first_pt[1], -70)
      done()
    )
  )
)

describe('add GeoJSON', ->
  it('uses GeoJSON Feature', (done) ->
    mapstore.add({ type: "Feature", geometry: { type: "Point", coordinates: [-70, 40] } }, (err, pt) ->
      assert.equal(pt.lat, 40)
      assert.equal(pt.lng, -70)
      done()
    )
  )

  it('uses GeoJSON string', (done) ->
    mapstore.add('{ "type": "Feature", "geometry": { "type": "Point", "coordinates": [-70, 40] } }', (err, pt) ->
      assert.equal(pt.lat, 40)
      assert.equal(pt.lng, -70)
      done()
    )
  )

  it('uses GeoJSON FeatureCollection', (done) ->
    mapstore.add({ type: "FeatureCollection", features: [{ type: "Feature", geometry: { type: "Point", coordinates: [-70, 40] } }]}, (err, pts) ->
      pt = pts[0]
      assert.equal(pt.lat, 40)
      assert.equal(pt.lng, -70)
      done()
    )
  )

  it('uses GeoJSON properties', (done) ->
    mapstore.add({ type: "Feature", geometry: { type: "Point", coordinates: [-70, 40] }, properties: { color: "#f00" } }, (err, pt) ->
      assert.equal(pt.lat, 40)
      assert.equal(pt.lng, -70)
      assert.equal(pt.properties.color, "#f00")

      mapstore.add('{ "type": "Feature", "geometry": { "type": "Point", "coordinates": [-70, 40] }, "properties": { "color": "#f00" } }', (err, pt) ->
        assert.equal(pt.lat, 40)
        assert.equal(pt.lng, -70)
        assert.equal(pt.properties.color, "#f00")
        done()
      )
    )
  )
)

describe('queries', ->
  it('returns a count of points added', (done) ->
    mapstore = new MapPLZ
    mapstore.add(40, -70)
    mapstore.add(40, -70)
    mapstore.count(null, (err, count) ->
      assert.equal(count, 2)
      done()
    )
  )

  it('deletes a point', (done) ->
    mapstore = new MapPLZ
    mapstore.add(40, -70, (err, pt) ->
      pt.delete ->
        mapstore.count(null, (err, count) ->
          assert.equal(count, 0)
          done()
        )
    )
  )

  it 'queries by property', (done) ->
    mapstore = new MapPLZ
    mapstore.add({ lat: 2, lng: 3, color: 'blue' }, (err, pt) ->
      mapstore.add({ lat: 2, lng: 3, color: 'red' }, (err, pt2) ->
        mapstore.query({ color: 'blue' }, (err, results) ->
          assert.equal(results.length, 1)
          assert.equal(results[0].properties.color, "blue")
          done()
        )
      )
    )

  it 'counts by property', (done) ->
    mapstore = new MapPLZ
    mapstore.add({ lat: 2, lng: 3, color: 'blue' }, (err, pt) ->
      mapstore.add({ lat: 2, lng: 3, color: 'red' }, (err, pt2) ->
        mapstore.count({ color: 'blue' }, (err, count) ->
          assert.equal(count, 1)
          done()
        )
      )
    )

  it 'finds nearest point', (done) ->
    mapstore = new MapPLZ
    mapstore.add { lat: 40, lng: -70 }, (err, pt) ->
      mapstore.add { lat: 35, lng: 110 }, (err, pt2) ->
        mapstore.near [30, -60], 1, (err, nearest) ->
          assert.equal(nearest.length, 1)
          response = nearest[0]
          assert.equal(response.lat, 40)
          assert.equal(response.lng, -70)
          done()

  it 'finds point in polygon', (done) ->
    mapstore = new MapPLZ
    mapstore.add { lat: 40, lng: -70 }, (err, pt) ->
      mapstore.add { lat: 35, lng: 110 }, (err, pt2) ->
        mapstore.inside [[[38, -72], [38, -68], [42, -68], [42, -72], [38, -72]]], (err, within) ->
          assert.equal(within.length, 1)
          nearest = within[0]
          assert.equal(nearest.lat, 40)
          assert.equal(nearest.lng, -70)
          done()
)

describe('strange inputs', ->
  it 'reads WKT string', (done) ->
    mapstore = new MapPLZ
    mapstore.add "LINESTRING(-70 40, -110 22)", (err, line) ->
      response = line.path[0]
      assert.equal(response[0], 40)
      assert.equal(response[1], -70)
      done()

  it 'reads csv string with lat and lng columns', (done) ->
    mapstore = new MapPLZ
    mapstore.add "lat,lng,label\n40,-70,banana", (err, pts) ->
      response = pts[0]
      assert.equal(response.lat, 40)
      assert.equal(response.lng, -70)
      done()

  it 'reads csv string with WKT column', (done) ->
    mapstore = new MapPLZ
    mapstore.add "wkt,label\nPOINT(-70 40),banana", (err, pts) ->
      response = pts[0]
      assert.equal(response.lat, 40)
      assert.equal(response.lng, -70)
      done()

  it 'reads mapplz code', (done) ->
    mapstore = new MapPLZ
    mapcode = "map\n"
    mapcode += "  marker\n"
    mapcode += "    [40, -70]\n"
    mapcode += "  plz\n"
    mapcode += "plz\n"
    mapstore.add mapcode, (err, pts) ->
      response = pts[0]
      assert.equal(response.lat, 40)
      assert.equal(response.lng, -70)
      done()
)
