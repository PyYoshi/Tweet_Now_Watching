###
@author PyYoshi
###

class TwitterWeb
  constructor: (twitterHtml=null,login=false,authToken=null,screenName=null,ssl=true) ->
    if ssl is true
      @scheme = 'https'
    else
      @scheme = 'http'
    @twitterHtmlDiv = document.createElement('div')
    if twitterHtml is null
      @twitterHtmlDiv.innerHTML = ''
      @login = login
      @authToken = authToken
      @screenName = screenName
    else
      @twitterHtmlDiv.innerHTML = twitterHtml
      @login = @isLogin()
      if @login
        @authToken = @getAuthToken()
        @screenName = @getUserScreenName()
      else
        @authToken = null
        @screenName = null
    return

  isLogin: () ->
    usernameEmailElementLength = document.evaluate('.//input[@id="username_or_email"]',@twitterHtmlDiv,null,XPathResult.UNORDERED_NODE_SNAPSHOT_TYPE,null).snapshotLength
    passwordElementLength = document.evaluate('.//input[@id="password"]',@twitterHtmlDiv,null,XPathResult.UNORDERED_NODE_SNAPSHOT_TYPE,null).snapshotLength
    LOGD("usernameEmailElementLength: " + usernameEmailElementLength)
    LOGD("passwordElementLength: " + passwordElementLength)
    if usernameEmailElementLength == 0 and passwordElementLength == 0 then return true
    return false

  getAuthToken: ()->
    authToken = document.evaluate('.//input[@name="authenticity_token"]',@twitterHtmlDiv,null,XPathResult.ORDERED_NODE_SNAPSHOT_TYPE,null).snapshotItem(0).value
    LOGD('authToken: '+authToken)
    return authToken

  getUserScreenName: () ->
    screenName = document.evaluate('.//h2[@class="current-user"]/a/span[@class="name"]',@twitterHtmlDiv,null,XPathResult.STRING_TYPE,null).stringValue
    LOGD('screenName: '+screenName)
    return screenName

  update: (msg=null,beforeSendHandler=null,successHandler=null,errorHandler=null)->
    postApiUrl = @scheme + '://twitter.com/intent/tweet/update'
    prepareData =
      authenticity_token:@authToken
      status:msg
    $.ajax postApiUrl,
      type: 'POST'
      dataType:'json'
      data:prepareData
      beforeSend: (jqXHR, settings)->
        beforeSendHandler(jqXHR, settings)
        return
      error:(jqXHR, textStatus, errorThrown) ->
        errorHandler(jqXHR, textStatus, errorThrown)
        return
      success:(data, textStatus, jqXHR) ->
        successHandler(data, textStatus, jqXHR)
        return
