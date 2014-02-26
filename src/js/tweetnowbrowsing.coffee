# 設定
DEBUG = false
MANIFEST = chrome.app.getDetails()
AppName = MANIFEST.name
MaxMsgLength = 140
TwitterLoginUrl = 'https://twitter.com/login'
AccessUrl = 'http://twitter.com/intent/tweet'
ReservedMsgLength = 20
# 初期値
DefaultPostHeader = 'NowBrowsing'
DefaultPostHeaderSplitter = ': '
DefaultStatusUrlSplitter = ' - '
DefaultDelayAccessSecond = 60 * 1000
DefaultShowNotificationSecond = 3 * 1000
# 使用するlocalStorageのKey一覧
PostHeaderKey = 'postHeader'
PostHeaderSplitterKey = 'postHeaderSplitter'
DelayAccessSecondKey = 'delayAccessSecond'
StatusUrlSplitterKey = 'statusUrlSplitter'
DelayAccessSecondKey = 'delayAccessSecond'
ShowNotificationSecondKey = 'showNotificationSecond'