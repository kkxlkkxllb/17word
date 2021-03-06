require('lib/setup')
Header = require("controllers/header")
Spine.Model.host = "http://17up.org"
$(document).on "deviceready", ->
	new Header(el: $("nav"))
	Spine.Route.setup()
	#(history: true)
	window.handleOpenURL = (url) ->
		console.log url
window.addEventListener 'load', ->
	FastClick.attach(document.body)
,false

$ ->
	$(".modal").on "click", ".close", ->
		$(".modal").removeClass "show"
	$notify = $(".md-modal")
	$overlay = $(".md-overlay")
	removeModal = ->
		$notify.removeClass "md-show"
		$overlay.removeClass "show"
		$(".disable_event").removeClass "disable_event"
	$notify.on "click",'.md-close',(ev) ->
		ev.stopPropagation()
		removeModal()
	$overlay.click ->
		removeModal()
