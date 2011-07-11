(function() {
  describe('set', function() {
    return it('doesnt have duplicates', function() {
      var s;
      s = set([1, 1]);
      return expect(s.length).toEqual(1);
    });
  });
}).call(this);
