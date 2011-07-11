EMPTY = ' '
EMPTY_GRAVITY = '~'
HORIZONTAL = 0
VERTICAL = 1

letterFrequencies = [
    ['a', .08167]
    ['b', .01492]
    ['c', .02782]
    ['d', .04253]
    ['e', .12702]
    ['f', .02228]
    ['g', .02015]
    ['h', .06094]
    ['i', .06966]
    ['j', .00153]
    ['k', .00772]
    ['l', .04025]
    ['m', .02406]
    ['n', .06749]
    ['o', .07507]
    ['p', .01929]
    ['q', .00095]
    ['r', .05987]
    ['s', .06327]
    ['t', .09056]
    ['u', .02758]
    ['v', .00978]
    ['w', .02360]
    ['x', .00150]
    ['y', .01974]
    ['z', .00074]
]


letters = 'abcdefghijklmnopqrstuvwxyz'
randomLetter = ->
    r = Math.random()

    low = 0
    for [letter, freq] in letterFrequencies
        high = low + freq
        if low <= r <= high
            break
        low = high


    return letter


displayAsEmpty = (x) -> x == EMPTY or x == EMPTY_GRAVITY

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
inDictionary = (word) ->
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

class WordInfo
    constructor: (@direction, @pt, @word) ->

    isWord: ->
        return inDictionary(@word)

    nextPoint: (pt) ->
        if pt == undefined
            return new Point(@pt)

        if @direction == HORIZONTAL
            return pt.add(new Point(1, 0))
        else
            return pt.add(new Point(0, 1))

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


letterColors = {}

for letter in letters
    letterColors[letter] = Raphael.getColor()

letterColors['~'] = '#000000'

class Player
    constructor: (ctx, @board) ->
        @rect = new Rect(@board.rect.x, @board.rect.bottom()-2, 2, 1)
        @setOrientation(HORIZONTAL)
        @board.bind 'newRow', =>
            @rect.y -= 1
    
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
        playSound(sounds.move)
        if @orientation == HORIZONTAL
            new Point(@rect.x + pos, @rect.y)
        else
            new Point(@rect.x, @rect.y + pos)

    swapLetters: ->
        words = @board.swap(@space(0), @space(1))
        @board.removeLongestWord(words)

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
    constructor: (@w, @h, @cellWidth, @cellHeight) ->
        @rowDelta = 0
        @pause = 0
        @rect = new Rect(0, 0, @w, @h)
        @cells = []
        @falls = []
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

    removeLongestWord: (words) ->
        if words.length
            words.sort (a, b) -> b.word.length - a.word.length
            wordInfo = words[0]
            @removeWord(wordInfo)
            playSound(sounds.word)
        @determineFalls()

    testStack: (pt) ->
        pt = new Point(pt.x, pt.y - 1)
        while pt.y >= 0
            if not displayAsEmpty(@get(pt))
                return true
            pt.y -= 1

        return false

    swap: (pt1, pt2) ->
        a = @get(pt1)
        b = @get(pt2)

        if a == EMPTY_GRAVITY or b == EMPTY_GRAVITY
            return []

        @set(pt1, b)
        @set(pt2, a)

        words = @test([pt1, pt2])
        
        return words

    test: (pts) ->
        words = []
        for row in (pt.y for pt in pts)
            words = words.concat(@testRow(row))
        for col in (pt.x for pt in pts)
            words = words.concat(@testCol(col))
        return words

    determineFalls: ->
        falling = []
        for y in [0..@rect.height-1]
            for x in [0..@rect.width-1]
                pt = new Point(x, y)
                if @get(pt) == EMPTY and @testStack(pt)
                    @set(pt, EMPTY_GRAVITY)
                    falling.push(pt)

        @fallLater(falling)

    fallLater: (cells) ->
        if cells.length
            @falls.push(
                now: @now
                time: @now + 350
                cells: cells
            )


    removeWord: (wordInfo) ->
        pt = wordInfo.nextPoint()
        length = wordInfo.word.length
        while length--
            @set(pt, EMPTY)
            pt = wordInfo.nextPoint(pt)

        $('#completedWords').append($('<span>').text(wordInfo.word))

        @addPause(600)

    # TODO: consolidate the next two sets of methods

    testRow: (row) ->
        words = []
        for wordWidth in [2..@rect.width]
            col = 0
            while col + wordWidth < @rect.width+1
                pt = new Point(col, row)
                wordInfo = @getHWord(pt, wordWidth)
                if wordInfo.isWord()
                    words.push(wordInfo)
                col += 1

        return words

    testCol: (col) ->
        words = []
        for wordHeight in [2..@rect.height]
            row = 0
            while row + wordHeight < @rect.height+1
                pt = new Point(col, row)
                wordInfo = @getVWord(pt, wordHeight)
                if wordInfo.isWord()
                    words.push(wordInfo)
                row += 1

        return words
    
    getHWord: (pt, wordLength) ->
        wordPt = new Point(pt)
        word = ''
        originalWordLength = wordLength
        while wordLength
            word += @cells[wordPt.y][wordPt.x]
            wordPt.x += 1
            wordLength -= 1
        return new WordInfo(HORIZONTAL, pt, word)

    getVWord: (pt, wordLength) ->
        wordPt = new Point(pt)
        word = ''
        originalWordLength = wordLength
        while wordLength
            word += @cells[wordPt.y][wordPt.x]
            wordPt.y += 1
            wordLength -= 1
        return new WordInfo(VERTICAL, pt, word)

    process: (delta) ->
        delta = @processTime(delta)

        @executeFalls()
        if not @gotNextRow
            @gotNextRow = true
            #nextRow = generateRow()

        @rowDelta += delta/12000
        if @rowDelta > 1
            @newRow()
            @rowDelta = 0

    processTime: (delta) ->
        if @pause > 0
            @pause -= delta
            return 0
        else
            if not @now
                @now = 0

            @now += delta
            return delta

    addPause: (pauseTime) ->
        @pause = pauseTime

    replaceFutureFalls: (source, dest) ->
        for fall in @falls
            for cell in fall.cells
                if cell.x == source.x and cell.y == dest.y
                    cell.x = dest.x
                    cell.y = dest.y

    executeFalls: ->
        while @falls.length and @falls[0].time < @now
            fallInfo = @falls.shift()
            toTest = []
            for cell in fallInfo.cells
                fallPt = new Point(cell)
                for y in [fallPt.y-1..0]
                    source = new Point(fallPt.x, y)
                    sourceLetter = @get(source)
                    dest = new Point(fallPt.x, fallPt.y)
                    toTest.push(dest)
                    @replaceFutureFalls(source, dest)
                    @set(dest, sourceLetter)
                    fallPt.y -= 1
                    
                    if displayAsEmpty(sourceLetter)
                        break

            @removeLongestWord(@test(toTest))

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
        @trigger('newRow')

    draw: () ->
        @ctx.textAlign = 'center'
        @ctx.textBaseline = 'middle'

        clipRect = new Rect(@rect.x, @rect.y, (@rect.width+4)*@cellWidth, (@rect.height-1)*@cellHeight)

        fallLookup = {}
        hadLookup = false
        delta = 0
        if @falls.length
            delta = (@now - @falls[0].now) / (@falls[0].time - @falls[0].now) * @cellHeight
            for cell in @falls[0].cells
                fallLookup[cell.x] = Math.max(fallLookup[cell.x] || 0, cell.y)
                hadLookup = true

        fallDelta = (x, y) ->
            if not hadLookup or not fallLookup[x]
                return 0
            if y >= fallLookup[x]
                return 0

            return delta

        x = 0
        y = 0
        @ctx.clipped clipRect, =>
            @ctx.translate(0, -@rowDeltaPixels())
            for row in @cells
                for letter in row
                    if not displayAsEmpty(letter)
                        xPos = x * @cellWidth
                        yPos = y * @cellHeight + fallDelta(x, y)

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

    generateCol: (startY, x, ensureNoWords) ->
        _doit = =>
            for y in [startY..@rect.height-1]
                @randomLetterAt(x, y)
        if ensureNoWords
            while ensureNoWords
                _doit()
                ensureNoWords = board.testCol(x).length > 0
        else
            _doit()


    @generateFreshBoard: (w, h) ->
        board = new Board(w, h, gridCellWidth, gridCellHeight)

        genCol = (startY, x) =>
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
                    board.generateCol(startY, col)

        return board

$.extend(Board.prototype, Events)

        
Game = ->
    canvas = $('#gameCanvas')[0]
    canvas.width = gridCellWidth * gameBoard.width
    canvas.height = gridCellHeight * (gameBoard.height-1)

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

        ctx.fillStyle = 'white';
        

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

window.sounds = {}

localPath = 'file:///c:/Users/Kevin/src/vocabattack/'

loadSound = (id, name) ->
    sounds[id] = soundManager.createSound
        id: id
        url: localPath + '/sounds/' + name
        autoLoad: true
        autoPlay: false
        volume: 50


window.soundSetup = ->
    if false
        $ ->
            soundManager.debugMode = false
            soundManager.url = localPath + '/lib/swf/'
            soundManager.onready ->
                loadSound('move', 'move.mp3')
                loadSound('word', 'word.mp3')

callAfter = (func) -> setTimeout(func, 0)

playSound = (sound) ->
    if false
        sound.play()

#E ×12, A ×9, I ×9, O ×8, N ×6, R ×6, T ×6, L ×4, S ×4, U ×4
#D ×4, G ×3
#B ×2, C ×2, M ×2, P ×2
#F ×2, H ×2, V ×2, W ×2, Y ×2
#K ×1
#J ×1, X ×1
#Q ×1, Z ×1
