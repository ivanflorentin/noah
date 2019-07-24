# context based web server
import httpbeast, options, asyncdispatch, json, uri, logging

import ../src/noah

var consoleLog = newConsoleLogger()

addHandler(consoleLog)

proc logError(ctx: WebContext) =
  let e = getCurrentException()
  error "====================== ERROR ====================="
  error ctx
  error getCurrentExceptionMsg()
  error e.getStackTrace()
  error "==================================================\n"



proc main(req: Request): Future[void]  =
  var resultContext: WebContext
  
  let ctx = createWebContext(req)
  echo ctx
  try:
    case $ctx.request.urlpath[0]:
      of "api":
        # We can call a controller here and return a context
        echo "api called"
        resultContext = ctx.copy()
        resultContext.response.body = """{"status": "ok"}"""
        
    if resultContext == nil:
      # ok, no results yet, lets try a file on the filesistem
      resultContext = readStaticFile(ctx)
        
    if resultContext != nil and resultContext.response != nil:
      let res = resultContext.response    
      # if res.headers present use send headers?
      # https://nim-lang.org/docs/asynchttpserver.html#sendHeaders
      if res.status.is4xx or res.status.is5xx:
        # if an error is created downstream, we log
        logError(ctx)
      req.send(res.status, res.body, $res.headers)
    else:
      # no response treat as serverside error
      logError(ctx)
      const headers = "Content-Type: text/plain"
      req.send(Http500, getCurrentExceptionMsg(), headers)
  except:
    logError(ctx)
    const headers = "Content-Type: text/plain"
    req.send(Http500, getCurrentExceptionMsg(), headers)
  
run main 
