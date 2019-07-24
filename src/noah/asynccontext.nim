import httpcore, strutils, uri, tables
import asynchttpserver
import webcontext

export webcontext

proc createWebContext*(r: Request): WebContext =
  ## Creates and encapsulates a new WebContext from a
  ## Request   
  result = new WebContext
  var req = new WRequest
  var res  = new WResponse
  req.body = r.body 
  req.hostname = r.hostname
  req.reqMethod = r.reqMethod
  req.url = r.url
  req.headers = r.headers
  req.protocol = r.protocol
  res.status = Http200
  res.headers = r.headers
  res.body = ""
  req.paramList = @[]
  req.paramTable = initTable[string, string]()
  let bpath = split($req.url, "?")
  if bpath.len > 0:
    req.urlpath = split(bpath[0], "/")
    req.urlpath.delete(0)
  else: 
    req.urlpath = @[]
  if bpath.len > 1:
    let params = split(bpath[1], "&")
    for p in params:
      if p.contains("="):
        let line = p.split("=")
        req.paramTable[line[0]] = line[1]
      else:
        req.paramList.add(p)
  
  result.request = req
  result.response = res
