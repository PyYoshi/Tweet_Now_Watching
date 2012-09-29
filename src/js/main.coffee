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
    $('#logo').text('Your tweet was over 140!')
    $('.headder').css('background','-webkit-gradient(linear,left top,left bottom,from(#cc0000),to(#ff3300))')
    $('span#logo').css('color','#FFFFFF')
    $('#post_button').attr("disabled", "disabled").css('background','')
  else
    LOGD('文字数オーバーしていません')
    $('#logo').text(AppName)
    $('.headder').css('background','-webkit-gradient(linear,left top,left bottom,from(#eaf4ff),to(#ffffff))')
    $('span#logo').css('color','#999999')
    $('#post_button').removeAttr("disabled").css('background','#DDD url(./media/bg-btn.gif) repeat-x 0 0')
  return

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
  return

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
    hashes["#{hash[0]}"] = decodeURIComponent(hash[1])
  LOGD(hashes)
  return hashes

$(
  ()->
    # 設定の読み出し
    PostHeader = getLocalStorage(PostHeaderKey,DefaultPostHeader)
    PostHeaderSplitter = getLocalStorage(PostHeaderSplitterKey,DefaultPostHeaderSplitter)
    StatusUrlSplitter = getLocalStorage(StatusUrlSplitterKey,DefaultStatusUrlSplitter)
    # 現在のquery stringを取得
    qhash = getQueryStringHash()
    #バッググラウンドスクリプト
    bg = chrome.extension.getBackgroundPage()
    # 文字数チェックイベント
    $('#text').bind('keyup change paste',()->
      countMsg()
      return
    )
    #ログインチェック
    logined = bg.isLogin()
    if logined
      LOGD('ログインしています。')
      chrome.tabs.getSelected(null,
        (tab)->
          # この関数内の処理を細分化したい
          if qhash.status and qhash.url
            preUpdateStatus = qhash.status
            url = qhash.url
          else
            preUpdateStatus = genStatusMsg(PostHeader,PostHeaderSplitter,tab.title,StatusUrlSplitter)
            url = tab.url
          $('#text').val(preUpdateStatus)
          $('#url').val(url)
          countMsg()
          $('#post_button').click(
            ()->
              countMsg()
              #nowCount = parseInt($('#char-count').text())
              LOGD(status)
              status = $('#text').val()+$('#url').val()
              if $('#create_tab_and_post').is(':checked')
                chrome.tabs.create({url:'https://twitter.com/intent/tweet?source=webclient&text='+encodeURIComponent(status)})
              else
                updateMsgPassing(status)
                window.close()
              return
          )
          $('body').keypress(
            (event)->
              LOGD(event)
              if event.ctrlKey and (event.keyCode is 13 or event.keyCode is 10)
                LOGD('Ctrl+Enterが押されました')
                $('#post_button').trigger('click')
              return
          )
          return
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
    #
)

