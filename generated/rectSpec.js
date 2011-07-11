(function() {
  describe('Point', function() {
    return it('can be added to', function() {
      return expect(new Point(5, 6).add(new Point(2, 3))).toEqual(new Point(7, 9));
    });
  });
  describe('Rect', function() {
    it('can be translated', function() {
      return expect(new Rect(5, 4, 20, 10).translate(new Point(2, 3))).toEqual(new Rect(7, 7, 20, 10));
    });
    it('compares equal', function() {
      return expect(new Rect(1, 2, 3, 4)).toEqual(new Rect(1, 2, 3, 4));
    });
    it('compares inequal', function() {
      return expect(new Rect(1, 2, 3, 4)).not.toEqual(new Rect(5, 6, 7, 8));
    });
    return it('can be clamped to another Rect', function() {
      var outer, r, r2;
      r = new Rect(5, 5, 3, 3);
      r2 = new Rect(-2, -2, 4, 3);
      outer = new Rect(0, 0, 7, 7);
      expect(r.clamp(outer)).toEqual(new Rect(4, 4, 3, 3));
      return expect(r2.clamp(outer)).toEqual(new Rect(0, 0, 4, 3));
    });
  });
}).call(this);
