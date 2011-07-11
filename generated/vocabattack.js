(function() {
  var Board, EMPTY, EMPTY_GRAVITY, Game, HORIZONTAL, Player, Point, Rect, VERTICAL, WordInfo, callAfter, clearCanvas, displayAsEmpty, gameBoard, gridCellHeight, gridCellWidth, inDictionary, keys, letter, letterColors, letterFrequencies, letters, loadSound, localPath, playSound, randomLetter, reqAnim, _i, _len;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  EMPTY = ' ';
  EMPTY_GRAVITY = '~';
  HORIZONTAL = 0;
  VERTICAL = 1;
  letterFrequencies = [['a', .08167], ['b', .01492], ['c', .02782], ['d', .04253], ['e', .12702], ['f', .02228], ['g', .02015], ['h', .06094], ['i', .06966], ['j', .00153], ['k', .00772], ['l', .04025], ['m', .02406], ['n', .06749], ['o', .07507], ['p', .01929], ['q', .00095], ['r', .05987], ['s', .06327], ['t', .09056], ['u', .02758], ['v', .00978], ['w', .02360], ['x', .00150], ['y', .01974], ['z', .00074]];
  letters = 'abcdefghijklmnopqrstuvwxyz';
  randomLetter = function() {
    var freq, high, letter, low, r, _i, _len, _ref;
    r = Math.random();
    low = 0;
    for (_i = 0, _len = letterFrequencies.length; _i < _len; _i++) {
      _ref = letterFrequencies[_i], letter = _ref[0], freq = _ref[1];
      high = low + freq;
      if ((low <= r && r <= high)) {
        break;
      }
      low = high;
    }
    return letter;
  };
  displayAsEmpty = function(x) {
    return x === EMPTY || x === EMPTY_GRAVITY;
  };
  $.extend(CanvasRenderingContext2D.prototype, {
    saved: function(func) {
      var res;
      this.save();
      res = func();
      this.restore();
      return res;
    },
    clipped: function(rect, func) {
      var res;
      res = void 0;
      this.saved(__bind(function() {
        this.rect(rect.x, rect.y, rect.width, rect.height);
        this.clip();
        return res = func();
      }, this));
      return res;
    },
    fillRoundedRect: function(x, y, w, h, r) {
      this.beginPath();
      this.moveTo(x + r, y);
      this.lineTo(x + w - r, y);
      this.quadraticCurveTo(x + w, y, x + w, y + r);
      this.lineTo(x + w, y + h - r);
      this.quadraticCurveTo(x + w, y + h, x + w - r, y + h);
      this.lineTo(x + r, y + h);
      this.quadraticCurveTo(x, y + h, x, y + h - r);
      this.lineTo(x, y + r);
      this.quadraticCurveTo(x, y, x + r, y);
      return this.fill();
    }
  });
  gridCellWidth = 40;
  gridCellHeight = 40;
  gameBoard = {
    width: 7,
    height: 12
  };
  clearCanvas = function(canvas) {
    return canvas.width = canvas.width;
  };
  window.dictionaryTrie = null;
  inDictionary = function(word) {
    return window.dictionaryTrie.test(word);
  };
  keys = {
    left: 37,
    up: 38,
    right: 39,
    down: 40,
    space: 32
  };
  reqAnim = window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame || function(callback, element) {
    return window.setTimeout(callback, 1000 / 30);
  };
  WordInfo = (function() {
    function WordInfo(direction, pt, word) {
      this.direction = direction;
      this.pt = pt;
      this.word = word;
    }
    WordInfo.prototype.isWord = function() {
      return inDictionary(this.word);
    };
    WordInfo.prototype.nextPoint = function(pt) {
      if (pt === void 0) {
        return new Point(this.pt);
      }
      if (this.direction === HORIZONTAL) {
        return pt.add(new Point(1, 0));
      } else {
        return pt.add(new Point(0, 1));
      }
    };
    return WordInfo;
  })();
  Rect = (function() {
    function Rect(x, y, width, height) {
      if (x instanceof Rect) {
        this.x = x.x;
        this.y = x.y;
        this.width = x.width;
        this.height = x.height;
      } else {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
      }
    }
    Rect.prototype.toString = function() {
      return '[Rect ' + this.x + ' ' + this.y + ' ' + this.width + ' ' + this.height + ']';
    };
    Rect.prototype.translate = function(pt) {
      return new Rect(this.x + pt.x, this.y + pt.y, this.width, this.height);
    };
    Rect.prototype.position = function() {
      return new Point(this.x, this.y);
    };
    Rect.prototype.left = function() {
      return this.x;
    };
    Rect.prototype.top = function() {
      return this.y;
    };
    Rect.prototype.bottom = function() {
      return this.height;
    };
    Rect.prototype.right = function() {
      return this.x + this.width;
    };
    Rect.prototype.clamp = function(rect) {
      var r;
      r = new Rect(this.x, this.y, this.width, this.height);
      if (r.x + r.width >= rect.right()) {
        r.x = rect.right() - r.width;
      }
      if (r.y + r.height >= rect.bottom()) {
        r.y = rect.bottom() - r.height;
      }
      if (r.x < rect.x) {
        r.x = rect.x;
      }
      if (r.y < rect.y) {
        r.y = rect.y;
      }
      return r;
    };
    return Rect;
  })();
  Point = (function() {
    Point.prototype.toString = function() {
      return "[Point " + this.x + " " + this.y + "]";
    };
    function Point(x, y) {
      if (x instanceof Point) {
        this.x = x.x;
        this.y = x.y;
      } else {
        this.x = x || 0;
        this.y = y || 0;
      }
    }
    Point.prototype.clamp = function(rect) {
      var pt;
      pt = new Point(this);
      if (pt.x < rect.x) {
        pt.x = rect.x;
      }
      if (pt.y < rect.y) {
        pt.y = rect.y;
      }
      if (pt.x >= rect.width) {
        pt.x = rect.width - 1;
      }
      if (pt.y >= rect.height) {
        pt.y = rect.height - 1;
      }
      return pt;
    };
    Point.prototype.add = function(otherPt) {
      return new Point(this.x + otherPt.x, this.y + otherPt.y);
    };
    return Point;
  })();
  letterColors = {};
  for (_i = 0, _len = letters.length; _i < _len; _i++) {
    letter = letters[_i];
    letterColors[letter] = Raphael.getColor();
  }
  letterColors['~'] = '#000000';
  Player = (function() {
    function Player(ctx, board) {
      this.board = board;
      this.rect = new Rect(this.board.rect.x, this.board.rect.bottom() - 2, 2, 1);
      this.setOrientation(HORIZONTAL);
      this.board.bind('newRow', __bind(function() {
        return this.rect.y -= 1;
      }, this));
    }
    Player.prototype.setOrientation = function() {
      return this.orientation = HORIZONTAL;
    };
    Player.prototype.left = function() {
      return this.delta(new Point(-1, 0));
    };
    Player.prototype.right = function() {
      return this.delta(new Point(1, 0));
    };
    Player.prototype.up = function() {
      return this.delta(new Point(0, -1));
    };
    Player.prototype.down = function() {
      return this.delta(new Point(0, 1));
    };
    Player.prototype.delta = function(pt) {
      var r;
      r = this.board.rect;
      return this.rect = this.rect.translate(pt).clamp(new Rect(r.x, r.y, r.width, r.height - 1));
    };
    Player.prototype.space = function(pos) {
      playSound(sounds.move);
      if (this.orientation === HORIZONTAL) {
        return new Point(this.rect.x + pos, this.rect.y);
      } else {
        return new Point(this.rect.x, this.rect.y + pos);
      }
    };
    Player.prototype.swapLetters = function() {
      var words;
      words = this.board.swap(this.space(0), this.space(1));
      return this.board.removeLongestWord(words);
    };
    Player.prototype.draw = function(ctx) {
      var height, width, x, y;
      x = this.rect.x * this.board.cellWidth;
      y = this.rect.y * this.board.cellHeight;
      width = this.rect.width * this.board.cellWidth;
      height = this.rect.height * this.board.cellHeight;
      ctx.strokeStyle = 'white';
      ctx.lineWidth = 5;
      return ctx.saved(function() {
        ctx.translate(0, -this.board.rowDeltaPixels());
        return ctx.strokeRect(x, y, width, height);
      });
    };
    return Player;
  })();
  Board = (function() {
    function Board(w, h, cellWidth, cellHeight) {
      var row, x, y, _ref, _ref2;
      this.w = w;
      this.h = h;
      this.cellWidth = cellWidth;
      this.cellHeight = cellHeight;
      this.rowDelta = 0;
      this.pause = 0;
      this.rect = new Rect(0, 0, this.w, this.h);
      this.cells = [];
      this.falls = [];
      for (y = 0, _ref = this.h - 1; 0 <= _ref ? y <= _ref : y >= _ref; 0 <= _ref ? y++ : y--) {
        row = [];
        for (x = 0, _ref2 = this.w - 1; 0 <= _ref2 ? x <= _ref2 : x >= _ref2; 0 <= _ref2 ? x++ : x--) {
          row.push(EMPTY);
        }
        this.cells.push(row);
      }
    }
    Board.prototype.rowDeltaPixels = function() {
      return this.rowDelta * this.cellHeight;
    };
    Board.prototype.set = function(pt, letter) {
      return this.cells[pt.y][pt.x] = letter;
    };
    Board.prototype.get = function(pt) {
      return this.cells[pt.y][pt.x];
    };
    Board.prototype.removeLongestWord = function(words) {
      var wordInfo;
      if (words.length) {
        words.sort(function(a, b) {
          return b.word.length - a.word.length;
        });
        wordInfo = words[0];
        this.removeWord(wordInfo);
        playSound(sounds.word);
      }
      return this.determineFalls();
    };
    Board.prototype.testStack = function(pt) {
      pt = new Point(pt.x, pt.y - 1);
      while (pt.y >= 0) {
        if (!displayAsEmpty(this.get(pt))) {
          return true;
        }
        pt.y -= 1;
      }
      return false;
    };
    Board.prototype.swap = function(pt1, pt2) {
      var a, b, words;
      a = this.get(pt1);
      b = this.get(pt2);
      if (a === EMPTY_GRAVITY || b === EMPTY_GRAVITY) {
        return [];
      }
      this.set(pt1, b);
      this.set(pt2, a);
      words = this.test([pt1, pt2]);
      return words;
    };
    Board.prototype.test = function(pts) {
      var col, pt, row, words, _j, _k, _len2, _len3, _ref, _ref2;
      words = [];
      _ref = (function() {
        var _k, _len2, _results;
        _results = [];
        for (_k = 0, _len2 = pts.length; _k < _len2; _k++) {
          pt = pts[_k];
          _results.push(pt.y);
        }
        return _results;
      })();
      for (_j = 0, _len2 = _ref.length; _j < _len2; _j++) {
        row = _ref[_j];
        words = words.concat(this.testRow(row));
      }
      _ref2 = (function() {
        var _l, _len3, _results;
        _results = [];
        for (_l = 0, _len3 = pts.length; _l < _len3; _l++) {
          pt = pts[_l];
          _results.push(pt.x);
        }
        return _results;
      })();
      for (_k = 0, _len3 = _ref2.length; _k < _len3; _k++) {
        col = _ref2[_k];
        words = words.concat(this.testCol(col));
      }
      return words;
    };
    Board.prototype.determineFalls = function() {
      var falling, pt, x, y, _ref, _ref2;
      falling = [];
      for (y = 0, _ref = this.rect.height - 1; 0 <= _ref ? y <= _ref : y >= _ref; 0 <= _ref ? y++ : y--) {
        for (x = 0, _ref2 = this.rect.width - 1; 0 <= _ref2 ? x <= _ref2 : x >= _ref2; 0 <= _ref2 ? x++ : x--) {
          pt = new Point(x, y);
          if (this.get(pt) === EMPTY && this.testStack(pt)) {
            this.set(pt, EMPTY_GRAVITY);
            falling.push(pt);
          }
        }
      }
      return this.fallLater(falling);
    };
    Board.prototype.fallLater = function(cells) {
      if (cells.length) {
        return this.falls.push({
          now: this.now,
          time: this.now + 350,
          cells: cells
        });
      }
    };
    Board.prototype.removeWord = function(wordInfo) {
      var length, pt;
      pt = wordInfo.nextPoint();
      length = wordInfo.word.length;
      while (length--) {
        this.set(pt, EMPTY);
        pt = wordInfo.nextPoint(pt);
      }
      $('#completedWords').append($('<span>').text(wordInfo.word));
      return this.addPause(600);
    };
    Board.prototype.testRow = function(row) {
      var col, pt, wordInfo, wordWidth, words, _ref;
      words = [];
      for (wordWidth = 2, _ref = this.rect.width; 2 <= _ref ? wordWidth <= _ref : wordWidth >= _ref; 2 <= _ref ? wordWidth++ : wordWidth--) {
        col = 0;
        while (col + wordWidth < this.rect.width + 1) {
          pt = new Point(col, row);
          wordInfo = this.getHWord(pt, wordWidth);
          if (wordInfo.isWord()) {
            words.push(wordInfo);
          }
          col += 1;
        }
      }
      return words;
    };
    Board.prototype.testCol = function(col) {
      var pt, row, wordHeight, wordInfo, words, _ref;
      words = [];
      for (wordHeight = 2, _ref = this.rect.height; 2 <= _ref ? wordHeight <= _ref : wordHeight >= _ref; 2 <= _ref ? wordHeight++ : wordHeight--) {
        row = 0;
        while (row + wordHeight < this.rect.height + 1) {
          pt = new Point(col, row);
          wordInfo = this.getVWord(pt, wordHeight);
          if (wordInfo.isWord()) {
            words.push(wordInfo);
          }
          row += 1;
        }
      }
      return words;
    };
    Board.prototype.getHWord = function(pt, wordLength) {
      var originalWordLength, word, wordPt;
      wordPt = new Point(pt);
      word = '';
      originalWordLength = wordLength;
      while (wordLength) {
        word += this.cells[wordPt.y][wordPt.x];
        wordPt.x += 1;
        wordLength -= 1;
      }
      return new WordInfo(HORIZONTAL, pt, word);
    };
    Board.prototype.getVWord = function(pt, wordLength) {
      var originalWordLength, word, wordPt;
      wordPt = new Point(pt);
      word = '';
      originalWordLength = wordLength;
      while (wordLength) {
        word += this.cells[wordPt.y][wordPt.x];
        wordPt.y += 1;
        wordLength -= 1;
      }
      return new WordInfo(VERTICAL, pt, word);
    };
    Board.prototype.process = function(delta) {
      delta = this.processTime(delta);
      this.executeFalls();
      if (!this.gotNextRow) {
        this.gotNextRow = true;
      }
      this.rowDelta += delta / 12000;
      if (this.rowDelta > 1) {
        this.newRow();
        return this.rowDelta = 0;
      }
    };
    Board.prototype.processTime = function(delta) {
      if (this.pause > 0) {
        this.pause -= delta;
        return 0;
      } else {
        if (!this.now) {
          this.now = 0;
        }
        this.now += delta;
        return delta;
      }
    };
    Board.prototype.addPause = function(pauseTime) {
      return this.pause = pauseTime;
    };
    Board.prototype.replaceFutureFalls = function(source, dest) {
      var cell, fall, _j, _len2, _ref, _results;
      _ref = this.falls;
      _results = [];
      for (_j = 0, _len2 = _ref.length; _j < _len2; _j++) {
        fall = _ref[_j];
        _results.push((function() {
          var _k, _len3, _ref2, _results2;
          _ref2 = fall.cells;
          _results2 = [];
          for (_k = 0, _len3 = _ref2.length; _k < _len3; _k++) {
            cell = _ref2[_k];
            _results2.push(cell.x === source.x && cell.y === dest.y ? (cell.x = dest.x, cell.y = dest.y) : void 0);
          }
          return _results2;
        })());
      }
      return _results;
    };
    Board.prototype.executeFalls = function() {
      var cell, dest, fallInfo, fallPt, source, sourceLetter, toTest, y, _j, _len2, _ref, _ref2, _results;
      _results = [];
      while (this.falls.length && this.falls[0].time < this.now) {
        fallInfo = this.falls.shift();
        toTest = [];
        _ref = fallInfo.cells;
        for (_j = 0, _len2 = _ref.length; _j < _len2; _j++) {
          cell = _ref[_j];
          fallPt = new Point(cell);
          for (y = _ref2 = fallPt.y - 1; _ref2 <= 0 ? y <= 0 : y >= 0; _ref2 <= 0 ? y++ : y--) {
            source = new Point(fallPt.x, y);
            sourceLetter = this.get(source);
            dest = new Point(fallPt.x, fallPt.y);
            toTest.push(dest);
            this.replaceFutureFalls(source, dest);
            this.set(dest, sourceLetter);
            fallPt.y -= 1;
            if (displayAsEmpty(sourceLetter)) {
              break;
            }
          }
        }
        _results.push(this.removeLongestWord(this.test(toTest)));
      }
      return _results;
    };
    Board.prototype.newRow = function() {
      var x, y, _ref, _ref2, _ref3;
      for (x = 0, _ref = this.rect.width - 1; 0 <= _ref ? x <= _ref : x >= _ref; 0 <= _ref ? x++ : x--) {
        if (this.get(new Point(x, y)) !== EMPTY) {
          alert('GAME OVER');
        }
      }
      for (y = 1, _ref2 = this.rect.height - 2; 1 <= _ref2 ? y <= _ref2 : y >= _ref2; 1 <= _ref2 ? y++ : y--) {
        for (x = 0, _ref3 = this.rect.width - 1; 0 <= _ref3 ? x <= _ref3 : x >= _ref3; 0 <= _ref3 ? x++ : x--) {
          this.set(new Point(x, y), this.get(new Point(x, y + 1)));
        }
      }
      this.generateRow(this.rect.height - 1, true);
      return this.trigger('newRow');
    };
    Board.prototype.draw = function() {
      var cell, clipRect, delta, fallDelta, fallLookup, hadLookup, x, y, _j, _len2, _ref;
      this.ctx.textAlign = 'center';
      this.ctx.textBaseline = 'middle';
      clipRect = new Rect(this.rect.x, this.rect.y, (this.rect.width + 4) * this.cellWidth, (this.rect.height - 1) * this.cellHeight);
      fallLookup = {};
      hadLookup = false;
      delta = 0;
      if (this.falls.length) {
        delta = (this.now - this.falls[0].now) / (this.falls[0].time - this.falls[0].now) * this.cellHeight;
        _ref = this.falls[0].cells;
        for (_j = 0, _len2 = _ref.length; _j < _len2; _j++) {
          cell = _ref[_j];
          fallLookup[cell.x] = Math.max(fallLookup[cell.x] || 0, cell.y);
          hadLookup = true;
        }
      }
      fallDelta = function(x, y) {
        if (!hadLookup || !fallLookup[x]) {
          return 0;
        }
        if (y >= fallLookup[x]) {
          return 0;
        }
        return delta;
      };
      x = 0;
      y = 0;
      return this.ctx.clipped(clipRect, __bind(function() {
        var letter, row, textX, textY, xPos, yPos, _k, _l, _len3, _len4, _ref2, _results;
        this.ctx.translate(0, -this.rowDeltaPixels());
        _ref2 = this.cells;
        _results = [];
        for (_k = 0, _len3 = _ref2.length; _k < _len3; _k++) {
          row = _ref2[_k];
          for (_l = 0, _len4 = row.length; _l < _len4; _l++) {
            letter = row[_l];
            if (!displayAsEmpty(letter)) {
              xPos = x * this.cellWidth;
              yPos = y * this.cellHeight + fallDelta(x, y);
              this.ctx.fillStyle = letterColors[letter];
              this.ctx.fillRoundedRect(xPos, yPos, this.cellWidth, this.cellHeight, 5);
              textX = xPos + this.cellWidth / 2;
              textY = yPos + this.cellHeight / 2;
              this.ctx.fillStyle = 'black';
              this.ctx.font = "bold 15px Helvetica, Arial";
              this.ctx.fillText(letter.toUpperCase(), textX + 1, textY + 1);
              this.ctx.fillStyle = 'white';
              this.ctx.fillText(letter.toUpperCase(), textX, textY);
            }
            x += 1;
          }
          y += 1;
          _results.push(x = 0);
        }
        return _results;
      }, this));
    };
    Board.prototype.randomLetterAt = function(x, y) {
      return this.set(new Point(x, y), randomLetter());
    };
    Board.prototype.generateRow = function(y, ensureNoWords) {
      var _doit, _results;
      _doit = __bind(function() {
        var x, _ref, _results;
        _results = [];
        for (x = 0, _ref = this.rect.width - 1; 0 <= _ref ? x <= _ref : x >= _ref; 0 <= _ref ? x++ : x--) {
          _results.push(this.randomLetterAt(x, y));
        }
        return _results;
      }, this);
      if (ensureNoWords) {
        _results = [];
        while (ensureNoWords) {
          _doit();
          _results.push(ensureNoWords = board.testRow(y).length > 0);
        }
        return _results;
      } else {
        return _doit();
      }
    };
    Board.prototype.generateCol = function(startY, x, ensureNoWords) {
      var _doit, _results;
      _doit = __bind(function() {
        var y, _ref, _results;
        _results = [];
        for (y = startY, _ref = this.rect.height - 1; startY <= _ref ? y <= _ref : y >= _ref; startY <= _ref ? y++ : y--) {
          _results.push(this.randomLetterAt(x, y));
        }
        return _results;
      }, this);
      if (ensureNoWords) {
        _results = [];
        while (ensureNoWords) {
          _doit();
          _results.push(ensureNoWords = board.testCol(x).length > 0);
        }
        return _results;
      } else {
        return _doit();
      }
    };
    Board.generateFreshBoard = function(w, h) {
      var board, checkAgain, col, genCol, row, startY, y, _ref, _ref2, _ref3;
      board = new Board(w, h, gridCellWidth, gridCellHeight);
      genCol = __bind(function(startY, x) {
        var y, _ref, _results;
        _results = [];
        for (y = 0, _ref = h - 1; 0 <= _ref ? y <= _ref : y >= _ref; 0 <= _ref ? y++ : y--) {
          _results.push(this.randomLetterAt(x, y));
        }
        return _results;
      }, this);
      startY = Math.floor(.5 * h);
      for (y = startY, _ref = h - 1; startY <= _ref ? y <= _ref : y >= _ref; startY <= _ref ? y++ : y--) {
        board.generateRow(y);
      }
      checkAgain = true;
      while (checkAgain) {
        checkAgain = false;
        for (row = 0, _ref2 = h - 1; 0 <= _ref2 ? row <= _ref2 : row >= _ref2; 0 <= _ref2 ? row++ : row--) {
          while (board.testRow(row).length > 0) {
            checkAgain = true;
            board.generateRow(row);
          }
        }
        for (col = 0, _ref3 = w - 1; 0 <= _ref3 ? col <= _ref3 : col >= _ref3; 0 <= _ref3 ? col++ : col--) {
          while (board.testCol(col).length > 0) {
            checkAgain = true;
            board.generateCol(startY, col);
          }
        }
      }
      return board;
    };
    return Board;
  })();
  $.extend(Board.prototype, Events);
  Game = function() {
    var animLoop, board, canvas, ctx, drawGrid, entities, game, player, prev, render;
    canvas = $('#gameCanvas')[0];
    canvas.width = gridCellWidth * gameBoard.width;
    canvas.height = gridCellHeight * (gameBoard.height - 1);
    ctx = canvas.getContext('2d');
    drawGrid = function(w, h) {
      var x, y, _ref, _results;
      ctx.strokeStyle = '#c0c0c0';
      ctx.lineWidth = .5;
      _results = [];
      for (y = 0, _ref = h - 1; 0 <= _ref ? y <= _ref : y >= _ref; 0 <= _ref ? y++ : y--) {
        _results.push((function() {
          var _ref2, _results2;
          _results2 = [];
          for (x = 0, _ref2 = w - 1; 0 <= _ref2 ? x <= _ref2 : x >= _ref2; 0 <= _ref2 ? x++ : x--) {
            _results2.push(ctx.strokeRect(x * gridCellWidth, y * gridCellHeight, gridCellWidth, gridCellHeight));
          }
          return _results2;
        })());
      }
      return _results;
    };
    board = Board.generateFreshBoard(gameBoard.width, gameBoard.height);
    board.ctx = ctx;
    window.board = board;
    player = new Player(ctx, board);
    $(document).keydown(function(e) {
      switch (e.keyCode) {
        case keys.right:
          return player.right();
        case keys.left:
          return player.left();
        case keys.down:
          return player.down();
        case keys.up:
          return player.up();
        case keys.space:
          return player.swapLetters();
      }
    });
    animLoop = function() {
      render();
      return reqAnim(animLoop);
    };
    entities = [board, player];
    prev = new Date().getTime();
    render = function() {
      var delta, entity, now, _j, _k, _len2, _len3, _results;
      now = new Date().getTime();
      delta = now - prev;
      prev = now;
      for (_j = 0, _len2 = entities.length; _j < _len2; _j++) {
        entity = entities[_j];
        if (entity.process) {
          entity.process(delta);
        }
      }
      clearCanvas(canvas);
      ctx.fillStyle = 'white';
      drawGrid(gameBoard.width, gameBoard.height - 1);
      _results = [];
      for (_k = 0, _len3 = entities.length; _k < _len3; _k++) {
        entity = entities[_k];
        _results.push(ctx.saved(function() {
          return entity.draw(ctx);
        }));
      }
      return _results;
    };
    game = {
      start: function() {
        if (!game.running) {
          game.running = true;
          return game.animLoop();
        }
      },
      animLoop: animLoop
    };
    return game;
  };
  window.dictionary_load = function(data) {
    var realData, word, _j, _len2;
    realData = [];
    for (_j = 0, _len2 = data.length; _j < _len2; _j++) {
      word = data[_j];
      if (word.length > 2) {
        realData.push(word);
      }
    }
    window.dictionaryTrie = Trie(realData);
    if (window.game) {
      return window.game.start();
    }
  };
  window.go = function() {
    window.game = Game();
    if (window.dictionaryTrie) {
      return game.start();
    }
  };
  window.Rect = Rect;
  window.Point = Point;
  window.sounds = {};
  localPath = 'file:///c:/Users/Kevin/src/vocabattack/';
  loadSound = function(id, name) {
    return sounds[id] = soundManager.createSound({
      id: id,
      url: localPath + '/sounds/' + name,
      autoLoad: true,
      autoPlay: false,
      volume: 50
    });
  };
  window.soundSetup = function() {
    return $(function() {
      soundManager.debugMode = false;
      soundManager.url = localPath + '/lib/swf/';
      return soundManager.onready(function() {
        loadSound('move', 'move.mp3');
        return loadSound('word', 'word.mp3');
      });
    });
  };
  callAfter = function(func) {
    return setTimeout(func, 0);
  };
  playSound = function(sound) {
    if (false) {
      return sound.play();
    }
  };
}).call(this);
