(function() {
  describe('extend', function() {
    return it('works on basic objects', function() {
      var a, b;
      a = {
        foo: 'bar'
      };
      b = {
        meep: 'baz'
      };
      extend(a, b);
      return expect(a.meep).toEqual('baz');
    });
  });
}).call(this);
