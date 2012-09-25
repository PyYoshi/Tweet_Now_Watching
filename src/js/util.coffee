###
@author PyYoshi
###

###
デバッグメッセージ表示用

@param msg {String} DEBUGが true: メッセージを表示 false: メッセージは表示されない
###
LOGD = (msg=null) ->
  if DEBUG is true then console.log(msg)

###
文字制限に合わせてページタイトルを整形し投稿用メッセージとして返す関数

@param postHeader {String} ポストヘッダー
@param postHeaderSplitter {String} ポストヘッダーとページタイトルを分ける文字列
@param title {String} タイトル
@param statusUrlSplitter {String} ページタイトルとURLを分ける文字列
@return {String} 整形済み投稿用メッセージ
###
genStatusMsg = (postHeader=null,postHeaderSplitter=null,title=null,statusUrlSplitter=null) ->
  LOGD('Cleeeeeeeeeeeeeeeeeeaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaan')
  threeDots = '...'
  maxTitleLength = MaxMsgLength - (postHeader.length+postHeaderSplitter.length+statusUrlSplitter.length+ReservedMsgLength)
  if title.length > maxTitleLength
    return postHeader+postHeaderSplitter+title.slice(0,maxTitleLength-threeDots.length)+threeDots+statusUrlSplitter
  else
    return postHeader+postHeaderSplitter+title+statusUrlSplitter

###
localStorageから値を取得する関数

@param targetKey {String} localStorageのkey
@param defaultValue {String||Number} デフォルト値
preturn {String||Number} localStorageから取得した値
###
getLocalStorage = (targetKey,defaultValue=null)->
  if targetKey is '' or typeof targetKey is 'undefined' or targetKey is null then return null
  if typeof localStorage["#{targetKey}"] is 'undefined' or localStorage["#{targetKey}"] is null
    return defaultValue
  else
    return localStorage["#{targetKey}"]

###
localStorageへ値をセットする関数

@param targetKey {String} localStorageのkey
@param value {String||Number}
@return {Boolean} true: セットできた false: セット出来なかった
###
setLocalStorage = (targetKey,value=null)->
  if targetKey is '' or typeof targetKey is 'undefined' or targetKey is null then return false
  if value is '' or typeof value is 'undefined' then return false
  try
    localStorage["#{targetkey}"] = value
    return true
  catch error
    LOGD('=== localStorageへ値を正常にセットできませんでした ===')
    LOGD(error)
    LOGD('======================================================')
    return false


