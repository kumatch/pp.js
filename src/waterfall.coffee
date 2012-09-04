pp.iterator = (procs) ->
  LIMIT = procs.length
  if LIMIT is 0
    return

  iteratorCache = []

  procByIndex = (index) ->
    if index < iteratorCache.length
      iteratorCache[index]
    else
      fn = ->
        procs[index].apply procs[index], __.slice.call arguments
        fn.next()
      fn.next = ->
        if index < LIMIT - 1
          procByIndex index + 1
        else
          null
      fn.clearCache = ->
        iteratorCache = []
      iteratorCache[index] = fn
      fn
  procByIndex 0

pp.waterfall = (procs, opt_callback) ->
  callback = opt_callback or __.id
  finished = no

  if procs.length is 1
    callback()
    return

  wrap = (iterator) ->
    wrapped = (error) ->
      return if finished
      if error
        finished = yes
        callback error
        return

      args =
        if 2 > arguments.length
        then []
        else __.slice.call arguments, 1

      next = iterator.next()
      if next
        args.unshift wrap next
      else
        args.unshift ->
          results = __.slice.call arguments
          callback.apply null, results
          iterator.clearCache()
          return

      __.defer ->
        iterator.apply iterator, args

  __.defer wrap pp.iterator procs