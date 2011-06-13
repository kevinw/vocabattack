describe 'Trie', ->
    it 'can have words inserted', ->
        t = new Trie(['pig'])
        expect(t.test('pig')).toEqual(true)
