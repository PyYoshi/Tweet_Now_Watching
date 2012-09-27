###
@author PyYoshi
###

saveOptions = ()->
  LOGD('save')
  setLocalStorage(PostHeaderKey,$('#customPostHeader').val())
  setLocalStorage(PostHeaderSplitterKey,$('#customPostHeaderSplitter').val())
  setLocalStorage(StatusUrlSplitterKey,$('#customStatusUrlSplitter').val())
  # ステータスにセーブしたことを通知する アニメーションがいいなぁ…
  $('#status').text('Saved it!').css('display','block')
  setInterval(
    ()->
      $('#status').text('').css('display','none')
      return
    5000
  )
  return

restoreOptions = ()->
  LOGD('restore')
  $('#customPostHeader').val(getLocalStorage(PostHeaderKey,DefaultPostHeader))
  $('#customPostHeaderSplitter').val(getLocalStorage(PostHeaderSplitterKey,DefaultPostHeaderSplitter))
  $('#customStatusUrlSplitter').val(getLocalStorage(StatusUrlSplitterKey,DefaultStatusUrlSplitter))
  return

resetOptions = (confirm)->
  LOGD('reset')
  if confirm
    LOGD('設定を初期化します。')
    setLocalStorage(PostHeaderKey,DefaultPostHeader)
    setLocalStorage(PostHeaderSplitterKey,DefaultPostHeaderSplitter)
    setLocalStorage(StatusUrlSplitterKey,DefaultStatusUrlSplitter)
    restoreOptions()
    # ステータスにリセットしたことを通知する アニメーションがいいなぁ…
    $('#status').text('Reseted it!').css('display','block')
    setInterval(
      ()->
        $('#status').text('').css('display','none')
        return
      5000
    )

  return

$(
  ()->
    # 設定のロード
    restoreOptions()
    #
    $('.customPostHeader').mouseover(
      ()->
        LOGD('.customPostHeader')
        return
    )
    #
    $('.customPostHeaderSplitter').mouseover(
      ()->
        LOGD('.customPostHeaderSplitter')
        return
    )
    #
    $('.customStatusUrlSplitter').mouseover(
      ()->
        LOGD('.customStatusUrlSplitter')
        return
    )
    #
    $('#resetButton').click(
      ()->
        LOGD('リセットボタンが押されました')
        ans = confirm('Are you sure you want to reset setting?')
        resetOptions(ans)
        return
    )
    #
    $('#saveButton').click(
      ()->
        LOGD('セーブボタンが押されました')
        saveOptions()
        return
    )
)