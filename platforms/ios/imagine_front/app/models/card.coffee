AjaxCard = require("models/ajax_card")
class Card extends Spine.Model
	@configure 'Card', 'title', 'content', 'raw_content',"image", 'pos',  "_id", "synset", "sync_over", "image_url", "lat", "lng", "altitude", "cap_at", "actived", "my_audio", "family", "quotes"
	@extend Spine.Model.Local
	@fetch: ->
		# @clean()
		if localStorage[@className]
			super()
		else
			$.getJSON "./api.json", (json) =>
				@refresh(json, clear: true)
	@clean: ->
		localStorage[@className] = []
	@unSync: ->
		@findAllByAttribute "sync_over", false
	@actived: ->
		w = @findByAttribute "actived", true
		w || @first()
	deactive: ->
		@updateAttributes
			actived: false
		@trigger "deactive"
	setActived: ->
		Card.actived().deactive()
		@updateAttributes
			actived: true
		@trigger "imagine"
	@search_by: (str) ->
		@select (item) ->
			item["title"].indexOf(str) > -1
	@search_by_cn: (str) ->
		@select (item) ->
			cn = item["raw_content"]["cn"][0]
			cn.text.indexOf(str) > -1
	@group_by: (letter) ->
		words = @select (item) ->
			item["title"].indexOf(letter) is 0
		# $.map words, (val,i) ->
		# 	val.title
	@exportAll: ->
		# TO-DO
		# find all image url and download to local
		this
	@fetchNew: ->
		# TO-DO
		# new week get new missions
		@export_all()
		@clean()
		@fetch()
		this

	getPics: (onSuccess,onFail) ->
		request_url = Spine.Model.host + "/api/cards/imagine"
		params =
			uuid: device.uuid
			id: @_id
		AjaxCard.ajaxQueue(
			data: params
			type: 'GET'
			url: request_url
		).done(onSuccess).fail(onFail)
	sync: (handler) ->
		img = @image
		Card.loadFile img,(blob) =>
			form = new FormData()
			form.append("image", blob)
			form.append("lat", @lat) if @lat
			form.append("lng", @lng) if @lng
			form.append("altitude", @altitude) if @altitude
			form.append("cap_at", @cap_at || new Date())
			form.append("_id",@_id)
			form.append("uuid",device.uuid)
			request_url = Spine.Model.host + "/api/cards/create"
			AjaxCard.ajaxQueue(
				type: 'POST'
				url: request_url
				data: form
				contentType: false
				processData: false
			).done(@syncSuccess).fail(@syncFail).done(handler)
	syncSuccess: (d) =>
		if d.status is 0
			img_url = Spine.Model.host + d.data
			@updateAttributes
				sync_over: true
				image_url: img_url
	syncFail: (err) =>
		@updateAttributes
			sync_over: false
		@trigger "badge:refresh"
	recognize_audio: (blob) ->
		form = new FormData()
		form.append("file", blob)
		form.append("_id",@_id)
		form.append("uuid",device.uuid)
		request_url = Spine.Model.host + "/api/cards/audio"
		AjaxCard.ajaxQueue(
			type: 'POST'
			url: request_url
			data: form
			contentType: false
			processData: false
		)
	@loadFile: (file,handler) ->
		path = file.split("file://")[1]
		fail = (error) ->
			console.log error
		readDataUrl = (file) ->
			reader = new FileReader()
			reader.onloadend = (evt) ->
				blob = dataURLtoBlob(evt.target.result)
				handler blob
			reader.readAsDataURL(file)
		gotFileEntry = (fileEntry) ->
			fileEntry.file(readDataUrl, fail)
		gotFS = (fileSystem) ->
			fileSystem.root.getFile(path, null, gotFileEntry, fail)
		requestFileSystem(LocalFileSystem.PERSISTENT, 0, gotFS, fail)
module.exports = Card
