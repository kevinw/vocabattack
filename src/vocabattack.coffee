EMPTY = ' '
HORIZONTAL = 0
VERTICAL = 1

keys =
    left: 37
    up: 38
    right: 39
    down: 40

letters = 'abcdefghijklmnopqrstuvwxyz'
randomLetter = -> letters[Math.floor(Math.random()*(letters.length))]
letterColors = {}

class Rect
    constructor: (@x, @y, @width, @height) ->

    bottom: -> @height - 1
    left: -> @x

class Point
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
        return Point(@x + otherPt.x, @y + otherPt.y)

for letter in letters
    letterColors[letter] = Raphael.getColor()

class Player
    constructor: (ctx, @board) ->
        @pos = new Point(@board.rect.left, @board.rect.bottom)
        @orientation = HORIZONTAL
        @el = ctx.rect(0, 0, @board.cellWidth*2, @board.cellHeight).attr
            stroke: 'red'
            fill: 'blue'
            'fill-opacity': '50%'
        @updateElem()

    left: -> delta(-1, 0)
    right: -> delta(1, 0)
    up: -> delta(0, -1)
    down: -> delta(0, 1)

    delta: (pt) ->
        @pos = @pos.add(pt).clamp(@board.rect)
        @updateElem()

    updateElem: ->
        @el.attr
            x: @pos.x
            y: @pos.y

class Board
    constructor: (@w, @h, @cellWidth, @cellHeight) ->
        @rect = new Rect(0, 0, @w, @h)
        @cells = []
        for y in [0..@h-1]
            row = []
            for x in [0..@w-1]
                row.push(EMPTY)
            @cells.push(row)

    set: (x, y, letter) ->
        @cells[y][x] = letter
    
    draw: (ctx) ->
        x = 0
        y = 0
        for row in @cells
            for letter in row
                if letter != EMPTY
                    xPos = x * @cellWidth
                    yPos = y * @cellHeight

                    r = ctx.rect(xPos, yPos, @cellWidth, @cellHeight, 5)
                    r.attr
                        fill: letterColors[letter]
                        stroke: 'none'

                    textX = xPos + @cellWidth/2
                    textY = yPos + @cellHeight / 2
                    textHighlight = ctx.text(textX+1, textY+1, letter).attr
                        fill: 'black'
                        'font-size': '15px'
                    textHighlight.blur(1)

                    text = ctx.text(textX, textY, letter).attr
                        fill: 'white'
                        'font-size': '15px'

                    letterBox = ctx.set([r, textHighlight, text])
                x += 1
            y += 1
            x = 0
        
        
Game = ->
    notepad = $('#notepad')
    ctx = Raphael('notepad', 640, 480)

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
                board.set(x, y, randomLetter())
        return board

    drawGrid(gameBoard.width, gameBoard.height)
    board = generateFreshBoard(gameBoard.width, gameBoard.height)
    board.draw(ctx)

    player = new Player(ctx, board)
    $(document).keydown (e) ->
        if e.keyCode == keys.right then player.right
        if e.keyCode == keys.left then player.left
        if e.keyCode == keys.down then player.down
        if e.keyCode == keys.up then player.up


go = ->
    game = Game()

$(go)

