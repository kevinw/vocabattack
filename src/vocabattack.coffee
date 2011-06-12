EMPTY = ' '
HORIZONTAL = 0
VERTICAL = 1

keys =
    left: 37
    up: 38
    right: 39
    down: 40
    space: 32

letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
randomLetter = -> letters[Math.floor(Math.random()*(letters.length))]
letterColors = {}

class Rect
    constructor: (x, y, width, height) ->
        if x instanceof Rect
            @x = x.x
            @y = x.y
            @width = x.width
            @height = x.height
        else
            @x = x
            @y = y
            @width = width
            @height = height

    toString: -> '[Rect ' + @x + ' ' + @y + ' ' + @width + ' ' + @height + ']'
    translate: (pt) -> new Rect(@x + pt.x, @y + pt.y, @width, @height)
    position: -> new Point(@x, @y)

    left: -> @x
    top: -> @y
    bottom: -> @height
    right: -> @x + @width

    clamp: (rect) ->
        r = new Rect(@x, @y, @width, @height)
        if r.x + r.width >= rect.right()
            r.x = rect.right() - r.width
        if r.y + r.height >= rect.bottom()
            r.y = rect.bottom() - r.height
        if r.x < rect.x
            r.x = rect.x
        if r.y < rect.y
            r.y = rect.y
        return r

class Point
    toString: -> "[Point " + @x + " " + @y + "]"

    constructor: (x, y) ->
        if x instanceof Point
            @x = x.x
            @y = x.y
        else
            @x = x || 0
            @y = y || 0

    clamp: (rect) ->
        pt = new Point(this)
        if pt.x < rect.x then pt.x = rect.x
        if pt.y < rect.y then pt.y = rect.y
        if pt.x >= rect.width then pt.x = rect.width - 1
        if pt.y >= rect.height then pt.y = rect.height - 1
        return pt

    add: (otherPt) ->
        new Point(@x + otherPt.x, @y + otherPt.y)

for letter in letters
    letterColors[letter] = Raphael.getColor()

class Player
    constructor: (ctx, @board) ->
        @rect = new Rect(@board.rect.x, @board.rect.bottom()-1, 2, 1)
        @setOrientation(HORIZONTAL)
        @el = ctx.rect(0, 0, @board.cellWidth*2, @board.cellHeight, 15).attr
            stroke: 'white'
            'stroke-width': '5px'
        @updateElem()
    
    setOrientation: ->
        @orientation = HORIZONTAL

    left: -> @delta(new Point(-1, 0))
    right: -> @delta(new Point(1, 0))
    up: -> @delta(new Point(0, -1))
    down: -> @delta(new Point(0, 1))

    delta: (pt) ->
        @rect = @rect.translate(pt).clamp(@board.rect)
        @updateElem()

    space: (pos) ->
        if @orientation == HORIZONTAL
            new Point(@rect.x + pos, @rect.y)
        else
            new Point(@rect.x, @rect.y + pos)

    swapLetters: ->
        @board.swap(@space(0), @space(1))

    updateElem: ->
        @el.animate({
            x: @rect.x * @board.cellWidth
            y: @rect.y * @board.cellHeight
            width: @rect.width * @board.cellWidth
            height: @rect.height * @board.cellHeight
        }, 15, 'backOut')

class Board
    constructor: (@w, @h, @cellWidth, @cellHeight) ->
        @rect = new Rect(0, 0, @w, @h)
        @cells = []
        for y in [0..@h-1]
            row = []
            for x in [0..@w-1]
                row.push(EMPTY)
            @cells.push(row)

    set: (pt, letter) ->
        @cells[pt.y][pt.x] = letter

    get: (pt) -> @cells[pt.y][pt.x]

    swap: (pt1, pt2) ->
        a = @get(pt1)
        b = @get(pt2)

        @set(pt1, b)
        @set(pt2, a)

    
    draw: () ->
        x = 0
        y = 0

        if @elset then @elset.remove()
        @elset = @ctx.set()
        
        for row in @cells
            for letter in row
                if letter != EMPTY
                    xPos = x * @cellWidth
                    yPos = y * @cellHeight

                    r = @ctx.rect(xPos, yPos, @cellWidth, @cellHeight, 5)
                    r.attr
                        fill: letterColors[letter]
                        stroke: 'none'

                    textX = xPos + @cellWidth/2
                    textY = yPos + @cellHeight / 2
                    textHighlight = @ctx.text(textX+1, textY+1, letter).attr
                        fill: 'black'
                        'font-size': '15px'
                    textHighlight.blur(1)

                    text = @ctx.text(textX, textY, letter).attr
                        fill: 'white'
                        'font-size': '15px'

                    @elset.push([r, textHighlight, text])
                x += 1
            y += 1
            x = 0
        
Game = ->
    notepad = $('#notepad')
    ctx = Raphael('notepad', window.innerWidth - 25, window.innerHeight - 25)

    gridCellWidth = 40
    gridCellHeight = 40

    gameBoard =
        width: 8
        height: 15

    drawGrid = (w, h) ->
        rects = []
        for y in [0..h-1]
            for x in [0..w-1]
                r = ctx.rect(x * gridCellWidth,
                             y * gridCellHeight,
                             gridCellWidth,
                             gridCellHeight)
                r.attr
                    stroke: '#efefef'
                rects.push(r)

        return rects


    generateFreshBoard = (w, h) ->
        board = new Board(w, h, gridCellWidth, gridCellHeight)
        for y in [Math.floor(.5*h)..h-1]
            for x in [0..w-1]
                board.set(new Point(x, y), randomLetter())
        return board

    drawGrid(gameBoard.width, gameBoard.height)
    board = generateFreshBoard(gameBoard.width, gameBoard.height)
    board.ctx = ctx
    board.draw()

    player = new Player(ctx, board)
    $(document).keydown (e) ->
        switch e.keyCode
            when keys.right then player.right()
            when keys.left then player.left()
            when keys.down then player.down()
            when keys.up then player.up()
            when keys.space then player.swapLetters()

go = ->
    game = Game()

$(go)


window.Rect = Rect
window.Point = Point

