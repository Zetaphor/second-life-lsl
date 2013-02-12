string my_url;
string main_url;
string current_page;
integer r;
integer display_face;
integer interactperm = PRIM_MEDIA_PERM_OWNER;

show(string html, integer face)
{
    html += "<span " + (string)((++r) % 10) + "/>";
 
    llSetPrimMediaParams(face,                  // Side to display the media on.
            [PRIM_MEDIA_AUTO_PLAY,TRUE,      // Show this page immediately
             PRIM_MEDIA_CURRENT_URL,html,    // The url if they hit 'home'
             PRIM_MEDIA_HOME_URL,html,       // The url currently showing
             PRIM_MEDIA_PERMS_INTERACT,interactperm,
             PRIM_MEDIA_PERMS_CONTROL,PRIM_MEDIA_PERM_NONE
             //PRIM_MEDIA_HEIGHT_PIXELS,512,   // Height/width of media texture will be
             //PRIM_MEDIA_WIDTH_PIXELS,512
             ]);  //   rounded up to nearest power of 2.
}
 
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

default
{
    state_entry()
    {
        display_face = (integer)llGetObjectDesc();
    }
    
    http_request(key id, string method, string body)
    {
        if (method == URL_REQUEST_GRANTED)
        {
            my_url = body;
            llMessageLinked(LINK_THIS,200000,body,"");            
        }
        else if (method == URL_REQUEST_DENIED)
        {
            llOwnerSay("Something went wrong, no url. " + body);
        }
        else if (method == "GET")
        {
            list path = llParseString2List(llGetHTTPHeader(id,"x-path-info"),["/"],[]);            
            if (llGetListLength(path)!=0)
            {
                if (llList2String(path,0) == "link")
                {
                    if (llList2String(path,1) != current_page)
                    {
                        current_page = llList2String(path,1);
                        show(build_url(main_url+"/link/"+current_page),display_face);
                        llOwnerSay("Loading URL...");                        
                    }
                }                    
            }
            else
            {
                current_page = "index";
                show(build_url(main_url),display_face);
                llOwnerSay("Loading URL...");
            }
        }
        else
        {
            llHTTPResponse(id,405,"Unsupported Method");
        }
    }
    
    link_message(integer se, integer n, string str, key id)
    {
        if (n == 200001)
        {
            llOwnerSay("Server started, displaying index page");
            main_url = str;
            show(build_url(main_url),display_face);
        }
        else if (n == 500000)
        {
            if (my_url!="")
            {
                llReleaseURL(my_url);
            }
            llRequestURL();            
        }            
        else if (n == 700000)
        {
            show(build_url(main_url+"/link/"+str),display_face);
        }  
        else if (n == 900000)
        {
            interactperm = (integer)str;
        }                  
    }
}
