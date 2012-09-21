class TwitterWeb
  constructor: (twitterHtml,ssl=true) ->
    if ssl is true
      @scheme = 'https'
    else
      @scheme = 'http'
    @login = @isLogin(twitterHtml)
    @authToken = @getAuthToken(twitterHtml)

  isLogin: (html) ->
    div = document.createElement('div')
    div.innerHTML = html
    usernameEmailElementLength = document.evaluate('.//input[@id="username_or_email"]',div,null,XPathResult.UNORDERED_NODE_SNAPSHOT_TYPE,null).snapshotLength
    passwordElementLength = document.evaluate('.//input[@id="password"]',div,null,XPathResult.UNORDERED_NODE_SNAPSHOT_TYPE,null).snapshotLength
    LOGD("usernameEmailElementLength: " + usernameEmailElementLength)
    LOGD("passwordElementLength: " + passwordElementLength)
    LOGD(div)
    if usernameEmailElementLength == 0 and passwordElementLength == 0 then return true
    return false

  getAuthToken: (html)->
    div = document.createElement('div')
    div.innerHTML = html
    authToken = document.evaluate('.//input[@name="authenticity_token"]',div,null,XPathResult.ORDERED_NODE_SNAPSHOT_TYPE,null).snapshotItem(0).value
    LOGD('authToken: '+authToken)
    return authToken

  update: (msg,successHandler,errorHandler)->
    # include_entities=true&include_cards=1&status=test&post_authenticity_token=9c95d8d28572f5df1fdc1875e8c91e352195bf66
    postApiUrl = @scheme + '://twitter.com/status/update'
    prepareData =
      authenticity_token:@authToken
      status:msg
      include_entities:'true'
      include_cards:'1'
    LOGD(prepareData)
    $.ajax postApiUrl,
      type: 'POST'
      dataType:'json'
      data:prepareData
      error:(jqXHR, textStatus, errorThrown) ->
        errorHandler(jqXHR, textStatus, errorThrown)
      success:(data, textStatus, jqXHR) ->
        successHandler(data, textStatus, jqXHR)








