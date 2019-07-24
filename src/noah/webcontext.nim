## A web context protocol that encapsulates the request and response

import httpcore, strutils, uri, asynchttpserver, tables

type    
  WRequest* = ref object
    ## Request encapsulation protocol
    hostname*, body*: string
    protocol*: tuple[orig: string, major, minor: int]
    reqMethod*: HttpMethod
    headers*: HttpHeaders
    url*: Uri
    urlpath*: seq[string]
    paramList*: seq[string]
    paramTable*: Table[string, string]
        
  WResponse* = ref object
    ## Response encapsulation Protocol
    status*: HttpCode
    headers*: HttpHeaders
    body*: string
    
  WebContext* = ref object
    request*: WRequest
    response*: WResponse
    

proc `$`*(r: WRequest): string =
  result = "hostname: " & r.hostname & " , method: " & $r.reqMethod &
    " , url: " & $r.url & " , headers: " & $r.headers &
    " , protocol" & $r.protocol & " , urlpath: " & $r.urlpath &
    " , paramList: " & $r.paramList &
    " , paramTable: " & $r.paramTable &
    " , body: " & $r.body
    

proc `$`*(r: WResponse): string =
  result = "status: " & $r.status & " ,headers: " & $r.headers &
    " , body: " & r.body

proc `$`*(c: WebContext): string =
  result = "WebContext: \nRequest: " & $c.request & "\nResponse: " & $c.response 


proc copy*(c: WebContext): WebContext =
  result = new WebContext
  var
    req = c.request
    res = c.response
  result.request = req
  result.response = res
  
