# TwitterWebの初期化
TwitterHtml = null
tw = new TwitterWeb()
# 起動時に読み込まれる設定なので、option.htmlにはChromeを再起動させないと反映されない趣旨を書く
DelayAccessSecond = getLocalStorage(DelayAccessSecondKey,DefaultDelayAccessSecond)
ShowNotificationSecond = getLocalStorage(ShowNotificationSecondKey,DefaultShowNotificationSecond)

###
ポップアイコンに表示するバッジをレンダリングする関数

@param badge {String} ポップアイコンに表示するテキスト
@param color {Array<R,G,B,A>} テキストの背景色
@param title {String} ポップアイコンにマウスオーバした時に表示するtips
###
renderBadge = (badge='',color=[65, 131, 196, 255],title=AppName) ->
  chrome.browserAction.setBadgeText(
    {text:badge}
  )
  chrome.browserAction.setBadgeBackgroundColor(
    {color:color}
  )
  chrome.browserAction.setTitle(
    {title:title}
  )
  return

###
Twitter Webのhtmlを取得する関数

@return {Deffered}
###
fetchTwitterWeb = () ->
  ajaxOpts =
    callback: 'callback'
    dataType: 'text'
  res = $.ajax(AccessUrl,ajaxOpts)
  return res

###
定期的にTwitter Webをチェックする関数
  一定間隔でfetchTwitterWeb()が実行される。
  非ログイン時はポップアイコンにバッジを表示して非ログインであることを知らせる
###
checkHtml = (repeat=true) ->
  $.when(fetchTwitterWeb()).then(
    (ajaxSuccessResArgs)->
      #LOGD('success')
      #LOGD(ajaxSuccessResArgs)
      TwitterHtml = ajaxSuccessResArgs
      tw.twitterHtmlDiv.innerHTML = TwitterHtml
      tw.login = tw.isLogin()
      if tw.login
        tw.authToken = tw.getAuthToken()
        tw.screenName = tw.getUserScreenName()
        color = [65, 131, 196, 255]
        badge = ''
        title = AppName
      else
        color = [166, 41, 41, 255]
        badge = '☹' # ☢ ☠
        title = 'You have to be connected to the internet and logged in to Twitter'
      renderBadge(badge,color,title)
      LOGD(tw)
      return
    (ajaxErrorResArgs)->
      #LOGD('failed')
      #LOGD(ajaxErrorResArgs)
      return
  ).done(
    ()->
      # メイン処理
      setTimeout(
        ()->
          if repeat then checkHtml()
          return
        DelayAccessSecond
      )
  )
  return

###
Desktop Notificationを作成する関数

@param title {String} Notificationに表示するタイトル(拡張名はセットしないこと)
@param body {String} Notificationに表示する本文(Not html)
@return {Notification} Notificationオブジェクト
###
createNotifer = (title=null,body=null)->
  ntf = webkitNotifications.createNotification(
    'media/48.png'
    title
    body
  )
  return ntf

###
###
getUserLatestPost = (screenName,call) ->


###
Twitter Web APIで投稿する関数

@param msg {String} 投稿するメッセージ
###
updateStatus = (msg=null) ->
  ntfPosting = createNotifer('posting...',msg)
  ntfDone = createNotifer('posting... Done',msg)
  tw.update(
    msg
    (jqXHR, settings) ->
      ntfPosting.show()
    (data, textStatus, jqXHR) ->
      LOGD(data)
      LOGD(jqXHR)
      tw.screenName
      if true # 厳密チェック
        LOGD()
      ntfPosting.close()
      ntfDone.show()
      setTimeout(
        ()->
          ntfDone.close()
          return
        ShowNotificationSecond
      )
      return
    (jqXHR, textStatus, errorThrown) ->
      # TODO: 失敗したらどうするか。エラー時は再投稿を促す？ 通知バーはそのまま。
      # ステータス更新のエラーはHTTPステータスコードでは判別できない。必ず200で返ってくる。
      # なので返ってきたjsonデータの投稿ステータスと比較する。 失敗すると投稿する前の最新のステータスが格納されている。
      LOGD(jqXHR)
      ntfPosting.close()
      ntfError = createNotifer('posting... Error',msg)
      ntfError.show()
      return
  )

###
Popupから送信されたメッセージオブジェクトをキャッチするイベントハンドラー
###
chrome.extension.onMessage.addListener(
  (request, sender, sendResponse)->
    LOGD('命令をを受け取りました。')
    LOGD(request)
    LOGD(sender)
    if request.sendCode is 'updateStatus'
      LOGD('投稿処理を行います。')
      updateStatus(request.msg)
      sendObject =
        status: 'success'
    else if request.sendCode is 'checkLogin'
      LOGD('ログインチェックを行います。')
      checkHtml(repead=false)
      sendObject =
        status:'success'
    else
      LOGD('不正なデータです。処理は無視されます。')
      sendObject =
        status: 'error'
    LOGD(sendObject)
    sendResponse(sendObject)
    return
)

###
BackgroundからPopupへログインチェックの結果を渡すための関数
  Popupから呼ばれます。

@return {Boolean} true:ログイン済み false:非ログイン
###
isLogin = ()->
  return tw.login

###
指定されたURLをポップアップさせる関数
###
popupWindow = (url=MANIFEST.browser_action.default_popup,
               windowName='I Love Python.', windowHeight=230, windowWitdh=320) ->
  windowOption = "height=#{windowHeight},width=#{windowWitdh},menubar=no,toolbar=no,location=no,status=no,resizable=yes,scrollbars=no"
  window.open(url,windowName,windowOption)

###
コンテキストメニューを作成する関数

@param title {String} コンテキストメニューのタイトル
@param contexs {Array<String>} 監視するイベントタイプ
@option parentId {Number} コンテキストメニューの親ID
@option onclick {Function(onClickData, tab)} クリック時のcallback関数
@option callback {Function()} コンテキストメニュー作成後に実行する関数
@return {Number} コンテキストメニューID
###
createContextMenus = (title=AppName,contexts=['all'],
                      parentId=null,onclick=null,callback=null) ->
  if onclick is null then onclick = (onClickData, tab)->
  if callback is null then callback = ()->
  options =
    title:title
    contexts:contexts
    onclick:onclick
  if parentId isnt null then options.parentId = parentId
  id = chrome.contextMenus.create(
    options
    callback
  )
  return id

###
コンテキストメニューを追加する関数
  選択文字から呼ばれた場合、それをメッセージにする。
  Share        : ポップアップを表示
  Share - Quick: ポップアップせずにそのまま投稿する
  Share - Quote: 引用をステータスにポップアップを表示
###
addContextMenus = ()->
  # 親コンテキストの作成
  parentContexts = ['all']
  parentId = createContextMenus(AppName,parentContexts,null,null,null)
  LOGD('parentId: '+parentId)
  # Shareコンテキストの作成
  childShareContexts = ['page']
  childShareOnClick = (onClickData, tab)->
    LOGD(onClickData)
    LOGD(tab)
    PostHeader = getLocalStorage(PostHeaderKey,DefaultPostHeader)
    PostHeaderSplitter = getLocalStorage(PostHeaderSplitterKey,DefaultPostHeaderSplitter)
    StatusUrlSplitter = getLocalStorage(StatusUrlSplitterKey,DefaultStatusUrlSplitter)
    status = genStatusMsg(PostHeader,PostHeaderSplitter,tab.title,StatusUrlSplitter)
    queryString = '?' + "status=#{encodeURIComponent(status)}&url=#{encodeURIComponent(tab.url)}"
    popupWindow(MANIFEST.browser_action.default_popup+queryString)
    return
  childShareId = createContextMenus('Share',childShareContexts,parentId,childShareOnClick,null)
  LOGD('childShareId: '+childShareId)
  # Share - Quickコンテキストの作成
  childQuickShareContexts = ['page']
  childQuickShareContextsOnClick = (onClickData, tab)->
    LOGD(onClickData)
    LOGD(tab)
    PostHeader = getLocalStorage(PostHeaderKey,DefaultPostHeader)
    PostHeaderSplitter = getLocalStorage(PostHeaderSplitterKey,DefaultPostHeaderSplitter)
    StatusUrlSplitter = getLocalStorage(StatusUrlSplitterKey,DefaultStatusUrlSplitter)
    status = genStatusMsg(PostHeader,PostHeaderSplitter,tab.title,StatusUrlSplitter) + tab.url
    updateStatus(status)
    return
  childQuickShareId = createContextMenus('Share - Quick',childQuickShareContexts,parentId,childQuickShareContextsOnClick,null)
  LOGD('childQuickShareId: '+childQuickShareId)
  # Share - Quoteコンテキストの作成(未実装)
  childQuoteShareContexts = ['selection']
  childQuoteShareOnClick = (onClickData, tab)->
    LOGD(onClickData)
    LOGD(tab)
    return
  #childQuoteShareId = createContextMenus('Share - Quote',childQuoteShareContexts,parentId,childQuoteShareOnClick,null)
  #LOGD('childQuoteShareId: '+childQuoteShareId)
  return
$(
  ()->
    checkHtml()
    addContextMenus()

    return
)

