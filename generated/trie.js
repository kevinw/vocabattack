(function() {
  window.set = function(iterable) {
    var hash, obj, set, _i, _len;
    set = [];
    hash = {};
    for (_i = 0, _len = iterable.length; _i < _len; _i++) {
      obj = iterable[_i];
      if (!hash[obj]) {
        set.push(obj);
        hash[obj] = true;
      }
    }
    return set;
  };
  window.Trie = function(dictionary) {
    var insert, trie, word, _i, _len;
    trie = {};
    insert = function(word, trie) {
      var char, child, next, _i, _len;
      if (word.length) {
        next = trie;
        for (_i = 0, _len = word.length; _i < _len; _i++) {
          char = word[_i];
          if (next[char]) {
            next = next[char];
          } else {
            child = {};
            next[char] = child;
            next = child;
          }
        }
        return next['|'] = true;
      }
    };
    for (_i = 0, _len = dictionary.length; _i < _len; _i++) {
      word = dictionary[_i];
      insert(word, trie);
    }
    return {
      test: function(str) {
        var char, next, _j, _len2;
        next = trie;
        for (_j = 0, _len2 = str.length; _j < _len2; _j++) {
          char = str[_j];
          if (next[char]) {
            next = next[char];
          } else {
            return null;
          }
        }
        return next['|'] === true;
      },
      trie: trie
    };
  };
}).call(this);
