# 設定
appTitle = 'Tweet: Now Browsing!'
DEBUG = true
defaultPostHeader = 'NowBrowsing'
postHeaderSpliter = ': '
maxMsgLength = 140
reservedMsgLength = 21 # url分 20 + 空白または改行分 1
twitterLoginUrl = 'https://twitter.com/login'


cleanPageTitle = (title,postHeaderLength) ->
  threeDots = '...'
  maxTitleLength = maxMsgLength - (reservedMsgLength + threeDots.length + postHeaderSpliter.length + postHeaderLength)
  if title.length > maxTitleLength then title = title.slice(0,maxTitleLength) + threeDots
  return title

countMsg = ->
  txt = $('#text').val()
  len = txt.length
  count = maxMsgLength - (len + reservedMsgLength)
  $('#char-count').text(count)

updateNotification = webkitNotifications.createNotification(
  'tw48.png',
  appTitle,
  'Posting...'
)

updateSuccessHandler = (data, textStatus, jqXHR) ->
  LOGD('==== 投稿に成功しました ====')
  LOGD(jqXHR)
  LOGD(data)
  postId = data['id_str']
  msg = data['text']
  screenName = data['user']['screen_name']
  LOGD('============================')
  return

updateErrorHandler = (jqXHR, textStatus, errorThrown) ->
  LOGD('投稿に失敗しました')
  LOGD(jqXHR)
  LOGD(errorThrown)
  LOGD('==================')
  return

window.onload = ->
  $('#text').val('processing...')
  # 文字数チェックイベント
  $('#text').bind('keyup change paste',()->
    txt = $(@).val()
    len = txt.length
    count = maxMsgLength - (len + reservedMsgLength)
    $('#char-count').text(count)
    return
  )

  # 投稿ボタンが押された時のイベント
  chrome.tabs.getSelected(null,
    (tab) ->
      url = 'http://twitter.com/intent/tweet?url=' + encodeURIComponent(tab.url)
      reqHeaders =
        'Accept-Language':'en-us'
      $.ajax url,
        dataType:'html'
        headers:reqHeaders
        error:(jqXHR, textStatus, errorThrown)->
          LOGD(jqXHR)
          LOGD(textStatus)
          LOGD(errorThrown)
          return
        success:(data, textStatus, jqXHR)->
          tw = new TwitterWeb(data)
          if tw.login == true
            LOGD('ログイン状態')
            postHeader = localStorage['customPostHeader']
            if not postHeader then postHeader = defaultPostHeader
            updateStatus = postHeader + postHeaderSpliter + cleanPageTitle(tab.title, postHeader.length)
            $('#text').val(updateStatus)
            $('#url').val(tab.url)
            countMsg()
            $('#post_button').click(
              ()->
                tw.update(updateStatus + ' ' +tab.url, updateSuccessHandler,updateErrorHandler)
            )
          else if tw.login == false
            LOGD('未ログイン状態')
            $('#post_button').val('Open twitter.com').bind('click',
              ()->
                chrome.tabs.create({'url':twitterLoginUrl})
            )
          else
            LOGD('何らかのエラー')

          return
  )




###
やりたいこと
  ポストが成功したかしていないかの有無をDesktop Notificationで行う https://developer.chrome.com/extensions/notifications.html
  140字以内であるかのチェックは投稿ボタンが押された時に行う
  右クリックメニューの追加 http://developer.chrome.com/extensions/contextMenus.html
  backgroud pages APIを使用して予めTwitterWebのhtmlを取得する？ http://developer.chrome.com/extensions/background_pages.html
    定期的にtwitterにアクセスしてログイン状況等を収集

  backgroudでポスト処理をして、notificationで成功したかどうか通知する？
    popup.htmlとMessage Passingを使用する http://developer.chrome.com/extensions/messaging.html


###
