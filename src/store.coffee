Object::length = ->
    size = 0

    for key of this
        size++ if this.hasOwnProperty(key)

    size

class exports.Store
    constructor: ->
        @emails = {}
        @ids = []

    add: (email) ->
        new_id = if @ids.length > 0 then @ids.slice(-1)[0] + 1 else 1

        @emails[new_id] = email
        @ids.push new_id

        new_id

    remove: (id) ->
        delete @emails[id]
        @ids.splice @ids.indexOf(id), 1