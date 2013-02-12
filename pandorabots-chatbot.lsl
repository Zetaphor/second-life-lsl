/////PANDORABOTS AI CHAT SCRIPT/////
////       By Zetaphor        /////
// 1) Create an account on Pandorabots.com
// 2) Create a new bot by following the sites instructions
// 3) Publish your bot
// 4) Take the botID from the URL, and replace the botID already here, or just use the one provided!
// 5) Enjoy

string url;
string botid="f754084f6e3690e9";
list params;
integer brainon;
default
{
    state_entry()
    {
        llListen(0, "", NULL_KEY, "");
    }

    touch_start(integer total_number)
    {
        if (brainon==TRUE)
        {
            llSay(0,"AI Chatbot Disabled!");
            brainon=FALSE;
        }
        else
        {
            llSay(0,"AI Chatbot Enabled!");
            brainon=TRUE;
        }
    }
    listen(integer channel, string name, key id, string message)
    {
        if (brainon==TRUE)
        {
            string url="http://www.pandorabots.com/pandora/talk-xml?botid="+botid+"&costid="+(string)llDetectedKey(0)+"&input="+llEscapeURL(message);
            llHTTPRequest(url,params,"");
        }
    }
    http_response(key request_id, integer status, list metadata, string body)
    {
        list response=llParseString2List(body,["<that>"],["</that>"]);
        llSay(0,llList2String(response,1));
    }    
