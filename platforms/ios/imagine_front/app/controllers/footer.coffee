Card = require("models/card")
Member = require("models/member")
class Footer extends Spine.Controller
	events:
		"click .sync": "sync"
		"click .light": "light"
		"click .share": "share"
	constructor: ->
		super
		Card.bind "badge:refresh", @render_badge
	light: (e) ->
		$("#info").html require("views/items/info")(Card.actived())
		$("#info").addClass("show")
	render_badge: ->
		$(".sync .badge",@$el).text Card.unSync().length
	sync: (e) ->
		$target = $(e.currentTarget)
		$target.addClass 'disable_event'
		if Member.checkConnection(Connection.WIFI)
			cards = Card.unSync()
			if cards.length > 0
				$target.find(".fa-refresh").addClass 'fa-spin'
				for card in cards
					card.sync().done =>
						@render_badge()
						if Card.unSync().length is 0
							$target.find(".fa-refresh").removeClass 'fa-spin'
							@notify("所有卡片都已同步到您的17up空间啦","恭喜","知道咯",$target)
			else
				@notify("没有发现未同步的卡片哦","恭喜","OK",$target)
		else if Member.checkConnection(Connection.NONE)
			@notify("系统未监测到网络，无法同步","遗憾","知道咯",$target)
		else
			@notify("建议在 WIFI 网络下执行同步，节省您的流量哦","友情提示","知道咯",$target)
	share: (e) ->
		# e.stopPropagation()
		card = Card.actived()
		if Member.checkConnection(Connection.NONE)
			@notify("系统未监测到网络，无法分享","遗憾","知道咯")
		else if card.image
			doShare = ->
				word = card.title
				message =
					text: "快来看我做的单词卡片 #{word}"
					image: card.image_url
				window.socialmessage.send(message)
			if card.sync_over
				doShare()
			else
				$target = $(e.currentTarget)
				$target.addClass 'disable_event'
				$target.find("span").addClass "fa-spin"
				card.sync ->
					card.trigger "badge:refresh"
					$target.find("span").removeClass "fa-spin"
					$target.removeClass 'disable_event'
					doShare()
		else
			@notify("你还没有拍照制作这张单词卡片呢！","ohh","知道咯")
	notify: (content,title,button,$target) ->
		cal = ->
			if $target
				$target.removeClass 'disable_event'
			false
		navigator.notification.alert content,cal,title,button
module.exports = Footer
