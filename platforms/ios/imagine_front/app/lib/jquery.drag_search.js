(function($) {
	(function() {
		var lastTime = 0;
		var vendors = ['ms', 'moz', 'webkit', 'o'];
		for(var x = 0; x < vendors.length && !window.requestAnimationFrame; ++x) {
				window.requestAnimationFrame = window[vendors[x]+'RequestAnimationFrame'];
				window.cancelAnimationFrame =
								window[vendors[x]+'CancelAnimationFrame'] || window[vendors[x]+'CancelRequestAnimationFrame'];
		}

		if (!window.requestAnimationFrame)
				window.requestAnimationFrame = function(callback, element) {
						var currTime = new Date().getTime();
						var timeToCall = Math.max(0, 16 - (currTime - lastTime));
						var id = window.setTimeout(function() { callback(currTime + timeToCall); },
										timeToCall);
						lastTime = currTime + timeToCall;
						return id;
				};

		if (!window.cancelAnimationFrame)
				window.cancelAnimationFrame = function(id) {
						clearTimeout(id);
				};
	}());

	function DragSearch(search_container,op){
		var self = this;
		var element = $(op.drag_container);
		var wraper = $(op.wraper);
		var search_input = $("input",$(search_container));
		var word_list = $(".container",$(search_container));
		var form = $(".form",$(search_container));
		var cancel = $(".cancel",$(search_container));
		var breakpoint = 175;
		var _slidedown_height = 0;
		var _anim = null;
		var _dragged_down = false;
		var field_height = 70;

		 function handleHammer(ev) {
			var self = this;

			switch(ev.type) {
				case 'release':
					if(!_dragged_down) {
						return;
					}
					cancelAnimationFrame(_anim);
					if(ev.gesture.deltaY < breakpoint) {
						hide();
					}else{
						search_input.focus();
						word_list.addClass("active");
						$("nav,article,footer").hide();
						setHeight(field_height,true);
					}
					break;

				case 'dragdown':
					_dragged_down = true;
					var scrollY = window.scrollY;
					if(scrollY > 5) {
						return;
					} else if(scrollY !== 0) {
						window.scrollTo(0,0);
					}
					if(!_anim) {
						updateHeight();
					}
					ev.gesture.preventDefault();
					_slidedown_height = ev.gesture.deltaY * 0.4;
					break;
			}
		 }

		 function setHeight(height,transition) {
		 	opacity = 1 - height*(1/70);
			if(transition){
				$(search_container).css({
					"webkitTransform": 'translate3d(0,'+height+'px,0) scale3d(1,1,1)',
					"-webkit-transition": "-webkit-transform 0.2s ease-in"
				});
				$("nav,article,footer").css({
					"opacity": opacity,
					"-webkit-transition": "opacity 0.2s ease-in"
				});
			}else{
				$(search_container).css({
					"webkitTransform": 'translate3d(0,'+height+'px,0) scale3d(1,1,1)',
					"-webkit-transition": "-webkit-transform 0s"
				});
				$("nav,article,footer").css({
					"opacity": opacity,
					"-webkit-transition": "opacity 0s"
				});
			}
		};

		function hide() {
			search_input.blur();
			word_list.removeClass("active");
			_slidedown_height = 0;
			setHeight(0,true);
			cancelAnimationFrame(_anim);
			_anim = null;
			_dragged_down = false;
			$("nav,article,footer").show();
		};

		function updateHeight() {
			var self = this;
			if(_slidedown_height >= field_height){

			}else {
				setHeight(_slidedown_height);
			}
			_anim = requestAnimationFrame(function() {
				updateHeight();
			});
		};
		cancel.on("click",function(){
			hide();
		});
		word_list.on("touchmove",function(e){
			search_input.blur();
		});
		form.on("touchmove",function(e){
			e.preventDefault();
		});
		element.hammer({ drag_lock_to_axis: true }).on("dragdown release",handleHammer);
	};

	$.fn.drag_search = function (options) {
		defaults = {
			drag_container: "article",
			wraper: "body"
		}
		new DragSearch(this,$.extend(defaults,options));
	 };
})(window.jQuery || window.Zepto);
