(function() {
  var reqAnim;
  reqAnim = window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame || function(callback, element) {
    return window.setTimeout(callback, 1000 / 60);
  };
  $(function() {
    var animLoop, ctx, notepad, render;
    notepad = $('#notepad')[0];
    notepad.width = window.innerHeight - 25;
    notepad.height = window.innerHeight - 25;
    if (!notepad.getContext) {
      return alert('canvas not supported');
    }
    ctx = notepad.getContext('2d');
    animLoop = function() {
      render();
      return reqAnim(animLoop);
    };
    render = function() {
      ctx.fillStyle = "red";
      return ctx.fillRect(0, 0, 180, 180);
    };
    return animLoop();
  });
}).call(this);
