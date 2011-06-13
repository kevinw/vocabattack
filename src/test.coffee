reqAnim =
  window.requestAnimationFrame       ||
  window.webkitRequestAnimationFrame ||
  window.mozRequestAnimationFrame    ||
  window.oRequestAnimationFrame      ||
  window.msRequestAnimationFrame     ||
  (callback, element) -> window.setTimeout(callback, 1000 / 60)

$ ->
    notepad = $('#notepad')[0]

    notepad.width = window.innerHeight - 25
    notepad.height = window.innerHeight - 25

    if not notepad.getContext
        return alert('canvas not supported')

    ctx = notepad.getContext('2d')

    animLoop = ->
        render()
        reqAnim(animLoop)

    render = ->
        ctx.fillStyle = "red"
        ctx.fillRect(0, 0, 180, 180)

    animLoop()

