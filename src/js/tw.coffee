###
@author PyYoshi
###

class TwitterBase
  LOGD()

class TwitterWeb
  constructor: (twitterHtml=null,login=false,authToken=null,ssl=true) ->
    if ssl is true
      @scheme = 'https'
    else
      @scheme = 'http'
    @twitterHtmlDiv = document.createElement('div')
    if twitterHtml is null
      @twitterHtmlDiv.innerHTML = ''
      @login = login
      @authToken = authToken
    else
      @twitterHtmlDiv.innerHTML = twitterHtml
      @login = @isLogin()
      @authToken = @getAuthToken()

  isLogin: () ->
    LOGD(@twitterHtmlDiv)
    usernameEmailElementLength = document.evaluate('.//input[@id="username_or_email"]',@twitterHtmlDiv,null,XPathResult.UNORDERED_NODE_SNAPSHOT_TYPE,null).snapshotLength
    passwordElementLength = document.evaluate('.//input[@id="password"]',@twitterHtmlDiv,null,XPathResult.UNORDERED_NODE_SNAPSHOT_TYPE,null).snapshotLength
    LOGD("usernameEmailElementLength: " + usernameEmailElementLength)
    LOGD("passwordElementLength: " + passwordElementLength)
    if usernameEmailElementLength == 0 and passwordElementLength == 0 then return true
    return false

  getAuthToken: ()->
    LOGD(@twitterHtmlDiv)
    authToken = document.evaluate('.//input[@name="authenticity_token"]',@twitterHtmlDiv,null,XPathResult.ORDERED_NODE_SNAPSHOT_TYPE,null).snapshotItem(0).value
    LOGD('authToken: '+authToken)
    return authToken

  update: (msg=null,beforeSendHandler=null,successHandler=null,errorHandler=null)->
    postApiUrl = @scheme + '://twitter.com/status/update'
    prepareData =
      authenticity_token:@authToken
      status:msg
    $.ajax postApiUrl,
      type: 'POST'
      dataType:'json'
      data:prepareData
      beforeSend: (jqXHR, settings)->
        beforeSendHandler(jqXHR, settings)
      error:(jqXHR, textStatus, errorThrown) ->
        errorHandler(jqXHR, textStatus, errorThrown)
      success:(data, textStatus, jqXHR) ->
        successHandler(data, textStatus, jqXHR)








