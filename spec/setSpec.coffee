describe 'set', ->
    it 'doesnt have duplicates', ->
        s = set([1,1])
        expect(s.length).toEqual(1)
        
