if typeof require is 'function'
  buster = require 'buster'
  pp = require '../lib/pp.js'

buster.testCase 'pp.each',
  'when receiver isnt function case, thorw error': (done) ->
    try
      pp.each (next, v) ->
        next null, v
      , 0, [1..5]
      assert no
    catch error
      assert error instanceof TypeError
      done()

  'when iterator isnt function, receive error': (done) ->
    pp.each 'not function', (error, result) ->
      assert error instanceof TypeError
      done()
    , [1..5]

  'when no problem, error is null': (done) ->
    pp.each (next) ->
      next()
    , (error) ->
      assert.isNull error
      done()
    , []

  'when invalid case, receive error': (done) ->
    pp.each (next, value) ->
      if typeof value isnt 'number'
        next new TypeError 'require number'
      else
        next()
    , (error) ->
      assert error instanceof TypeError
      assert.equals error.message, 'require number'
      done()
    , [1, 2, 'not number value', 3, 4]

  'each iteration is incremental step': (done) ->
    count = 0
    params = [1..10]
    pp.each (next, value, index) ->
      assert.same index, count
      count++
      next()
    , (error) ->
      assert.same count, params.length
      count = 0
      done()
    , params

  '<example> each overwrite values to x^2': (done) ->
    params = [1..5]
    pp.each (next, value, index, iterable) ->
      iterable[index] = value * value
      next()
    , (error) ->
      expect(error).toBeNull()
      expect(params).toEqual [1, 4, 9, 16, 25]
      done()
    , params
