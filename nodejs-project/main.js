var http = require("http");
console.log("start server");
var nodeServer = http.createServer((request, response) => {
  console.log("request.method: " + request.method);
  console.log("request.method is get: " + equest.method.toLowerCase === 'get');
  console.log("request.url: " + request.url);

  if (request.method.toLowerCase === 'get') {
      var result = eval(request.url.split('code=')[1])
      console.log("result: " + result);
      response.end("Versions: " + result);
  } else if (request.method.toLowerCase == 'post') {
    response.end("post: not implementation.");
  } else {
      response.end("Versions: " + JSON.stringify(process.versions));
  }
});
console.log("start server end!");
nodeServer.listen(3000);
