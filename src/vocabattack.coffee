EMPTY = ' '
HORIZONTAL = 0
VERTICAL = 1

$.extend(CanvasRenderingContext2D.prototype, {
    saved: (func) ->
        this.save()
        res = func()
        this.restore()
        return res

    clipped: (rect, func) ->
        res = undefined
        @saved =>
            @rect(rect.x, rect.y, rect.width, rect.height)
            @clip()
            res = func()
        return res

    fillRoundedRect: (x, y, w, h, r) ->
        @beginPath()
        @moveTo(x+r, y)
        @lineTo(x+w-r, y)
        @quadraticCurveTo(x+w, y, x+w, y+r)
        @lineTo(x+w, y+h-r)
        @quadraticCurveTo(x+w, y+h, x+w-r, y+h)
        @lineTo(x+r, y+h)
        @quadraticCurveTo(x, y+h, x, y+h-r)
        @lineTo(x, y+r)
        @quadraticCurveTo(x, y, x+r, y)
        @fill()
})


gridCellWidth = 40
gridCellHeight = 40

gameBoard =
    width: 7
    height: 12
clearCanvas = (canvas) -> canvas.width = canvas.width

window.dictionaryTrie = null
isWord = (word) ->
    window.dictionaryTrie.test(word)

keys =
    left: 37
    up: 38
    right: 39
    down: 40
    space: 32

reqAnim =
  window.requestAnimationFrame       ||
  window.webkitRequestAnimationFrame ||
  window.mozRequestAnimationFrame    ||
  window.oRequestAnimationFrame      ||
  window.msRequestAnimationFrame     ||
  (callback, element) -> window.setTimeout(callback, 1000 / 30)

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

letters = 'abcdefghijklmnopqrstuvwxyz'
randomLetter = -> letters[Math.floor(Math.random()*(letters.length))]

letterColors = {}

for letter in letters
    letterColors[letter] = Raphael.getColor()

class Player
    constructor: (ctx, @board) ->
        @rect = new Rect(@board.rect.x, @board.rect.bottom()-2, 2, 1)
        @setOrientation(HORIZONTAL)
        #$(@board).bind 'newRow', =>
            #@rect.y += 1
    
    setOrientation: ->
        @orientation = HORIZONTAL

    left: -> @delta(new Point(-1, 0))
    right: -> @delta(new Point(1, 0))
    up: -> @delta(new Point(0, -1))
    down: -> @delta(new Point(0, 1))

    delta: (pt) ->
        r = @board.rect
        @rect = @rect.translate(pt).clamp(new Rect(r.x, r.y, r.width, r.height-1))

    space: (pos) ->
        if @orientation == HORIZONTAL
            new Point(@rect.x + pos, @rect.y)
        else
            new Point(@rect.x, @rect.y + pos)

    swapLetters: ->
        words = @board.swap(@space(0), @space(1))
        words.sort (a, b) -> b.word.length - a.word.length
        if words.length
            wordInfo = words[0]
            @board.removeWord(wordInfo)

    draw: (ctx) ->
        x = @rect.x * @board.cellWidth
        y = @rect.y * @board.cellHeight
        width = @rect.width * @board.cellWidth
        height = @rect.height * @board.cellHeight

        ctx.strokeStyle = 'white'
        ctx.lineWidth = 5

        ctx.saved ->
            ctx.translate(0, -@board.rowDeltaPixels())
            ctx.strokeRect(x, y, width, height)

class Board
    $.extend(this, Events)
    constructor: (@w, @h, @cellWidth, @cellHeight) ->
        @rowDelta = 0
        @rect = new Rect(0, 0, @w, @h)
        @cells = []
        for y in [0..@h-1]
            row = []
            for x in [0..@w-1]
                row.push(EMPTY)
            @cells.push(row)

    rowDeltaPixels: ->
        return @rowDelta * @cellHeight

    set: (pt, letter) ->
        @cells[pt.y][pt.x] = letter

    get: (pt) -> @cells[pt.y][pt.x]

    swap: (pt1, pt2) ->
        a = @get(pt1)
        b = @get(pt2)

        @set(pt1, b)
        @set(pt2, a)

        words = []
        for row in set([pt1.y, pt2.y])
            words = words.concat(@testRow(row))
        for col in set([pt1.x, pt2.x])
            words = words.concat(@testCol(col))
        
        return words

    removeWord: (wordInfo) ->
        pt = new Point(wordInfo.pt)
        length = wordInfo.wordLength

        while length--
            @set(pt, EMPTY)
            fallPt = new Point(pt)
            for y in [pt.y-1..1]
                sourceLetter = @get(new Point(fallPt.x, y))
                dest = new Point(fallPt.x, fallPt.y)
                @set(dest, sourceLetter)
                fallPt.y -= 1
            pt = pt.add(new Point(1, 0))

        $('#completedWords').append($('<div>').text(wordInfo.word))

    testRow: (row) ->
        words = []
        for wordWidth in [2..@rect.width]
            col = 0
            while col + wordWidth < @rect.width+1
                pt = new Point(col, row)
                wordInfo = @getHWord(pt, wordWidth)
                if isWord(wordInfo.word)
                    words.push(wordInfo)
                col += 1

        return words

    getHWord: (pt, wordLength) ->
        wordPt = new Point(pt)
        word = ''
        originalWordLength = wordLength
        while wordLength
            word += @cells[wordPt.y][wordPt.x]
            wordPt.x += 1
            wordLength -= 1
        return {pt: pt, wordLength: originalWordLength, word: word}

    testCol: (col) ->
        return []
    
    process: (delta) ->
        if not @gotNextRow
            @gotNextRow = true
            #nextRow = generateRow()

        @rowDelta += delta/12000
        if @rowDelta > 1
            @newRow()
            @rowDelta = 0

    newRow: ->
        # check for game over state
        for x in [0..@rect.width-1]
            if @get(new Point(x, y)) != EMPTY
                alert('GAME OVER')

        # move all blocks up one
        for y in [1..@rect.height-2]
            for x in [0..@rect.width-1]
                @set(new Point(x, y), @get(new Point(x, y+1)))

        # fill in new row
        @generateRow(@rect.height-1, true)
        #$(this).trigger('newRow')

    draw: () ->
        x = 0
        y = 0

        @ctx.textAlign = 'center'
        @ctx.textBaseline = 'middle'

        clipRect = new Rect(@rect.x, @rect.y, (@rect.width+4)*@cellWidth, (@rect.height-1)*@cellHeight)

        @ctx.clipped clipRect, =>
            @ctx.translate(0, -@rowDeltaPixels())
            for row in @cells
                for letter in row
                    if letter != EMPTY
                        xPos = x * @cellWidth
                        yPos = y * @cellHeight

                        # colored background
                        @ctx.fillStyle = letterColors[letter]
                        @ctx.fillRoundedRect(xPos, yPos, @cellWidth, @cellHeight, 5)

                        textX = xPos + @cellWidth/2
                        textY = yPos + @cellHeight / 2

                        # shadow
                        @ctx.fillStyle = 'black'
                        @ctx.font = "bold 15px Helvetica, Arial"
                        @ctx.fillText(letter.toUpperCase(), textX+1, textY+1)

                        # text
                        @ctx.fillStyle = 'white'
                        @ctx.fillText(letter.toUpperCase(), textX, textY)

                    x += 1
                y += 1
                x = 0

    randomLetterAt: (x, y) ->
        @set(new Point(x, y), randomLetter())

    generateRow: (y, ensureNoWords) ->
        _doit = =>
            for x in [0..@rect.width-1]
                @randomLetterAt(x, y)

        if ensureNoWords
            while ensureNoWords
                _doit()
                ensureNoWords = board.testRow(y).length > 0
        else
            _doit()


    @generateFreshBoard: (w, h) ->
        board = new Board(w, h, gridCellWidth, gridCellHeight)

        genCol = (startY, x) ->
            for y in [0..h-1]
                @randomLetterAt(x, y)

        startY = Math.floor(.5*h)

        for y in [startY..h-1]
            board.generateRow(y)

        checkAgain = true
        while checkAgain
            checkAgain = false
            for row in [0..h-1]
                while board.testRow(row).length > 0
                    checkAgain = true
                    board.generateRow(row)

            for col in [0..w-1]
                while board.testCol(col).length > 0
                    checkAgain = true
                    genCol(startY, col)

        return board

        
Game = ->
    canvas = $('#gameCanvas')[0]
    canvas.width = 400
    canvas.height = window.innerHeight - 25
    ctx = canvas.getContext('2d')

    drawGrid = (w, h) ->
        ctx.strokeStyle = '#c0c0c0'
        ctx.lineWidth = .5
        for y in [0..h-1]
            for x in [0..w-1]
                ctx.strokeRect(x * gridCellWidth,
                             y * gridCellHeight,
                             gridCellWidth,
                             gridCellHeight)

    board = Board.generateFreshBoard(gameBoard.width, gameBoard.height)
    board.ctx = ctx
    window.board = board # TODO: remove

    player = new Player(ctx, board)
    $(document).keydown (e) ->
        switch e.keyCode
            when keys.right then player.right()
            when keys.left then player.left()
            when keys.down then player.down()
            when keys.up then player.up()
            when keys.space then player.swapLetters()

    animLoop = ->
        render()
        reqAnim(animLoop)

    entities = [board, player]

    prev = new Date().getTime()
    render = ->
        now = new Date().getTime()
        delta = now - prev
        prev = now

        for entity in entities
            if entity.process
                entity.process(delta)

        clearCanvas(canvas)

        drawGrid(gameBoard.width, gameBoard.height-1)
        
        for entity in entities
            ctx.saved ->
                entity.draw(ctx)

    game = {
        start: ->
            if not game.running
                game.running = true
                game.animLoop()
        animLoop: animLoop
    }

    return game

window.dictionary_load = (data) ->
    realData = []
    for word in data
        if word.length > 2
            realData.push(word)

    window.dictionaryTrie = Trie(realData)
    if window.game
        window.game.start()

window.go = ->
    window.game = Game()
    if window.dictionaryTrie
        game.start()

window.Rect = Rect
window.Point = Point

