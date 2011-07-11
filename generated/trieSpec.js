(function() {
  describe('Trie', function() {
    return it('can have words inserted', function() {
      var t;
      t = new Trie(['pig']);
      return expect(t.test('pig')).toEqual(true);
    });
  });
}).call(this);
