window.set = (iterable) ->
    set = []
    hash = {}
    for obj in iterable
        if not hash[obj]
            set.push(obj)
            hash[obj] = true
    return set

window.Trie = (dictionary) ->
  trie = {}
  
  insert = (word, trie) ->
    if word.length
      next = trie
      
      for char in word
        if next[char]
          next = next[char]
        else
          child = {}
          next[char] = child
          next = child
      
      next['|'] = true
  
  for word in dictionary
    insert(word, trie)
  
  # returns true for a word, null for a segment and false otherwise
  return {
      test: (str) ->
        next = trie
        
        for char in str
          if (next[char])
            next = next[char]
          else
            return null
        
        return next['|'] == true
      trie: trie
  }

