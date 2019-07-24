import strutils, uri, httpcore, os, mimetypes, md5
import webcontext

const staticDir = "public"

proc readStaticFile*(ctx: WebContext): WebContext =
  result = ctx.copy()
  var requestedfile = $ctx.request.url
  if requestedfile == "" or requestedfile == "/":
    requestedfile = "/index.html"
  let filename = os.getCurrentDir() & "/" & staticDir & requestedfile
  let mimedb = newMimetypes()

  # echo "Current dir: " & os.getCurrentDir()
  # echo "Static dir: " & staticDir
  # echo "Filename : " & filename
  if filename.existsFile():
    #echo "File exists"
    let fp = filename.getFilePermissions()
    if not fp.contains(fpOthersRead):
      #echo "forbidden file" 
      result.response.status = Http403
      result.response.body = """{"error": "forbidden"}"""
      return
    let fileSize = filename.getFileSize()
    let filext = filename.splitFile.ext[1 .. ^1]
    var mimetype = "text/plain"
    if filext == "json":
      #mimetype = "text/plain"
      mimetype = "application/json"
      #mimetype = "text/javascript"
    else: 
      mimetype = mimedb.getMimetype(filext)
    #echo "mimetype: " & $mimetype 
    if fileSize < 10_000_000: # 10 mb
      #echo "will read the file"
      var file = filename.readFile()
      var hashed = getMD5(file)
      
      # If the user has a cached version of this file and it matches our
      # version, let them use it
      if ctx.request.headers.hasKey("If-None-Match") and ctx.request.headers["If-None-Match"] == hashed:
        result.response.status = Http304
        result.response.headers = newHttpHeaders()
        result.response.body = ""
        return
      else:
        #echo "will return content"
        result.response.status = Http200
        result.response.body = file & " "
        #echo "response body: " & $result.response.body
        result.response.headers = newHttpHeaders(@({"Content-Type": mimetype,"ETag": hashed }))
        return
  else:
    echo "File not found"
    result.response.status = Http404
    result.response.body = """{"status": 404, "error": "file not found"}"""
    
  

