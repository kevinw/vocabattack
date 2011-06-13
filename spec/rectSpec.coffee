describe 'Point', ->
    it 'can be added to', ->
        expect(new Point(5, 6).add(new Point(2, 3))).toEqual(new Point(7, 9))

describe 'Rect', ->
    it 'can be translated', ->
        expect(new Rect(5, 4, 20, 10)
                   .translate(new Point(2, 3)))
            .toEqual(new Rect(7, 7, 20, 10))

    it 'compares equal', ->
        expect(new Rect(1,2,3,4)).toEqual(new Rect(1,2,3,4))

    it 'compares inequal', ->
        expect(new Rect(1,2,3,4)).not.toEqual(new Rect(5,6,7,8))

    it 'can be clamped to another Rect', ->
        r = new Rect(5, 5, 3, 3)
        r2 = new Rect(-2, -2, 4, 3)
        outer = new Rect(0, 0, 7, 7)

        expect(r.clamp(outer)).toEqual(new Rect(4, 4, 3, 3))
        expect(r2.clamp(outer)).toEqual(new Rect(0, 0, 4, 3))


