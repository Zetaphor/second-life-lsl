This is the bit that makes it all work, from the [_GatewayController](/HyperMedia%20Toolkit/_Gateway%20Controller.lsl).

```C#
  // This creates a data: url that will render the output of the http-in url 
  // given.
  string build_url(string burl)
  {
      return "data:text/html," 
          + llEscapeURL("<html><head><script src='" + burl 
          + "' type='text/javascript'></script></head><body onload='init()'></body></html>");
  }

  // This wraps the html you want to display so that it will be shown from links 
  // made with build_url
  string build_response(string body)
  {
      return "function init() {document.getElementsByTagName('body')[0].innerHTML='" + body + "';}";
  }
```
