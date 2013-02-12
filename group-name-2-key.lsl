string url_prefix = "http://world.secondlife.com/group/";
string result_start = "<title>";
string result_end = "</title>";
list requests;
list kGroup; 

GroupName(key find){
    string url = url_prefix+(string)find;
    key id = llHTTPRequest(url, [], "");
    requests += [id,find];
}

default{
//
    changed(integer c){
        if(c & CHANGED_OWNER){llResetScript(); 
        }
    }
//
    touch_start(integer d){
        requests = [];
        kGroup = llGetObjectDetails(llGetKey(), [OBJECT_GROUP]);
        //llSay(0,(string)llList2Key(kGroup,0));
        GroupName(llList2String(kGroup,0));
    }
//
    http_response(key request_id, integer status, list metadata, string body){
        integer p = llListFindList(requests,[request_id]);
        if (p != -1){
            body = llUnescapeURL(body);
            string group_key = llList2Key(requests,p+1);
            integer name_start = llSubStringIndex(body,result_start)+llStringLength(result_start);
            integer name_end = llSubStringIndex(body,result_end)-1;
            string group_name = llGetSubString(body,name_start,name_end);
            llSay(0,"/me >> This objects group name is \""+group_name+"\".");
            requests = llDeleteSubList(requests,p,p+1);
        }
    }
//
}
