###
@author PyYoshi
###


###
入力された文字数のチェックを行う関数
###
countMsg = () ->
  txt = $('#text').val()
  len = txt.length
  count = MaxMsgLength - (len + ReservedMsgLength)
  $('#char-count').text(count)
  if count < 0
    LOGD('文字数オーバー')
    # TODO: 投稿ボタンの無効化


###
バッググラウンドへ投稿するメッセージを送信する関数

@param msg {String} 投稿するメッセージ
###
updateMsgPassing = (msg=null) ->
  sendObject =
    msg:msg
    sendCode:'updateStatus'
  chrome.extension.sendMessage(
    sendObject
    (response)->
      LOGD('バッググランドへメッセージを投稿するように命令しました。')
      LOGD(response)
      return
  )

###
現在のロケーションからクエリーを取得する関数

@return {Object}
###
getQueryStringHash = () ->
  hashes = {}
  startIndex = window.location.href.indexOf('?')
  if startIndex is -1 then return {}
  queries = window.location.href.slice(startIndex + 1).split('&')
  LOGD(queries)
  for query in queries
    hash = query.split('=')
    hashes["#{hash[0]}"] = hash[1]
  LOGD(hashes)
  return hashes

$(
  ()->
    PostHeader = getLocalStorage(PostHeaderKey,DefaultPostHeader)
    PostHeaderSplitter = getLocalStorage(PostHeaderSplitterKey,DefaultPostHeaderSplitter)
    StatusUrlSplitter = getLocalStorage(StatusUrlSplitterKey,DefaultStatusUrlSplitter)
    # 現在のquery stringを取得
    qhash = getQueryStringHash()
    #バッググラウンドスクリプト
    bg = chrome.extension.getBackgroundPage()
    # 文字数チェックイベント
    $('#text').bind('keyup change paste',()->
      txt = $(@).val()
      len = txt.length
      count = MaxMsgLength - (len + ReservedMsgLength)
      $('#char-count').text(count)
      return
    )
    #ログインチェック
    logined = bg.isLogin()
    if logined
      LOGD('ログインしています。')
      chrome.tabs.getSelected(null,
        (tab)->
          # この関数内の処理を細分化したい
          preUpdateStatus = PostHeader + PostHeaderSplitter + cleanPageTitle(tab.title, PostHeader.length)
          $('#text').val(preUpdateStatus)
          $('#url').val(tab.url)
          countMsg()
          $('#post_button').click(
            ()->
              updateStatus = $('#text').val()+StatusUrlSplitter+$('#url').val()
              LOGD(updateStatus)
              updateMsgPassing(updateStatus)
              window.close()
              return
          )
      )
    else if logined is false
      LOGD('ログインしていません。')
      chrome.tabs.create({'url':TwitterLoginUrl})
      window.close()
    else
      LOGD('何らかのエラー。')
      window.close()

    LOGD(getQueryStringHash())
    return
)

