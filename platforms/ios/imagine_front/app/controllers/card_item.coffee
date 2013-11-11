Card = require("models/card")
Member = require("models/member")
class CardItem extends Spine.Controller
	className: "card_item"
	events:
		"hold": "make"
		"click": "playAudio"
	constructor: ->
		super
		@item.bind "deactive", @release
	render: =>
		@html require("views/items/card")(@item)
	make: (e) ->
		e.preventDefault()
		$target = $(e.currentTarget)
		$target.addClass 'disable_event'
		card = @item

		option =
			quality: 70
			targetWidth: 640
			targetHeight: 857
			# saveToPhotoAlbum: true
			destinationType: Camera.DestinationType.DATA_URL
			# correctOrientation: false
			# allowEdit: true
		onFail = (msg) ->
			console.log msg
			$target.removeClass 'disable_event'
		onSuccess = (imageData) =>
			b64img = "data:image/jpeg;base64," + imageData
			$img = $("img.u_word",@$el)
			$img.attr "src", b64img
			$img.animo
				animation: 'tada'
			$target.removeClass 'disable_event'
			saveImg = (c) ->
				blob = dataURLtoBlob(b64img)
				Member.writeImage blob,c.title,(path) ->
					c.image = "file://" + path
					c.save()
					c.syncFail()
			onSuccess = (position) ->
				card.lat = position.coords.latitude
				card.lng = position.coords.longitude
				card.altitude = position.coords.altitude
				card.cap_at = position.timestamp
				saveImg(card)

			onError = (error) ->
				console.log error.code + error.message
				card.cap_at = new Date()
				saveImg(card)
			# 获取拍摄照片时的位置信息并保存，触发同步
			navigator.geolocation.getCurrentPosition(onSuccess, onError)
		navigator.camera.getPicture onSuccess, onFail, option
	playAudio: (e) ->
		unless Member.checkConnection(Connection.NONE)
			src = "http://tts.yeshj.com/uk/s/" + encodeURIComponent(@item.title)
			Member.playSound(src)
	record: (e) ->
		$target = $(e.currentTarget)
		$target.addClass "recording"
		filename = "mySound"
		uploadMedia = (base64) ->
			card = Card.actived()
			blob = dataURLtoBlob(base64)
			$target.removeClass "recording"
			card.recognize_audio(blob)
		Member.recordMedia(filename,uploadMedia)
module.exports = CardItem
