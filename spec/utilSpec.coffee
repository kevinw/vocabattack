describe 'extend', ->
    it 'works on basic objects', ->
        a = {foo: 'bar'}
        b = {meep: 'baz'}
        extend(a, b)
        expect(a.meep).toEqual('baz')
