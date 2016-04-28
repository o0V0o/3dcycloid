var Trackball = function(){
	var trackballMove = false
	var lastx  = 0
	var lasty  = 0
	var startx = 0
	var starty = 0
	var dx = 0
	var dy = 0
	

	function motion(){
		return [dx, dy]
	}
	function reset(){
		dx=0
		dy=0
	}
	function mouseMotion(x,y){
		dx=dx+(x-lastx)
		dy=dy+(y-lasty)
		lastx = x
		lasty = y
	}
	function mousePos(){
		return [lastx, lasty]
	}
	function register(canvas){
		canvas.addEventListener('mousedown', function(event){
			var canvasSize = Math.min(canvas.clientWidth, canvas.clientHeight)/2
			startx = (event.clientX-(canvas.clientWidth/2))/canvasSize
			starty = (event.clientY-(canvas.clientHeight/2))/canvasSize
			lastx = startx
			lasty = starty
			trackballMove = true
		})
		canvas.addEventListener('mouseup', function(event){ trackballMove = false})
		canvas.addEventListener('mousemove', function(event){
			if (trackballMove){
				var canvasSize = Math.min(canvas.clientWidth, canvas.clientHeight)/2
				var x = (event.clientX-(canvas.clientWidth/2))/canvasSize
				var y = (event.clientY-(canvas.clientHeight/2))/canvasSize
				mouseMotion( x, y )
			}
		})
	}
	// return our *exported* interface
	return {register:register, motion:motion, reset:reset, mousePos:mousePos, mouseMotion:mouseMotion}
}()
