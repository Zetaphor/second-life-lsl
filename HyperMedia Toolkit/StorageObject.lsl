string page_name;
integer page_num;
key lquery;
integer nline;

string page_data;

string check_line(string text)
{
    list parcelinfo = llGetParcelDetails(llGetPos(),[PARCEL_DETAILS_NAME,PARCEL_DETAILS_DESC]);
    while(llSubStringIndex(text,"%SIM%")!=-1)
    {
        integer index = llSubStringIndex(text,"%SIM%");
        text = llDeleteSubString(text,index,index+4);
        text = llInsertString(text,index,llGetRegionName());
    }
    while(llSubStringIndex(text,"%POSITION%")!=-1)
    {
        integer index = llSubStringIndex(text,"%POSITION%");
        text = llDeleteSubString(text,index,index+9);
        text = llInsertString(text,index,(string)llGetPos());
    }
    while(llSubStringIndex(text,"%PARCELNAME%")!=-1)
    {
        integer index = llSubStringIndex(text,"%PARCELNAME%");
        text = llDeleteSubString(text,index,index+11);
        text = llInsertString(text,index,llList2String(parcelinfo,0));
    }
    while(llSubStringIndex(text,"%PARCELDESC%")!=-1)
    {
        integer index = llSubStringIndex(text,"%PARCELDESC%");
        text = llDeleteSubString(text,index,index+11);
        text = llInsertString(text,index,llList2String(parcelinfo,1));
    }
    while(llSubStringIndex(text,"%ONAME%")!=-1)
    {
        integer index = llSubStringIndex(text,"%ONAME%");
        text = llDeleteSubString(text,index,index+6);
        text = llInsertString(text,index,llGetObjectName());
    }  
    while(llSubStringIndex(text,"%APPURL%")!=-1)
    {
        integer index = llSubStringIndex(text,"%APPURL%");
        text = llDeleteSubString(text,index,index+7);
        vector pos = llGetPos();
        text = llInsertString(text,index,"secondlife://"+llGetRegionName()+"/"+(string)llFloor(pos.x)+"/"+(string)llFloor(pos.x)+"/"+(string)llFloor(pos.z));
    }             
    while(llSubStringIndex(text,"%ODESC%")!=-1)
    {
        integer index = llSubStringIndex(text,"%ODESC%");
        text = llDeleteSubString(text,index,index+6);
        text = llInsertString(text,index,llGetObjectDesc());
    }             
    while(llSubStringIndex(text,"%TEXTUREID:")!=-1)
    {
        integer count=1;
        integer index = llSubStringIndex(text,"%TEXTUREID:");
        integer found;
        string check;
        integer end_index;
        while (found==FALSE)
        {
            check = llGetSubString(text,index+count,index+count);
            if (check=="%"){found=TRUE;end_index = index+count;}
            count++;
        }
        string link = llGetSubString(text,index,end_index);
        text = llDeleteSubString(text,index,end_index);
        list temp = llParseString2List(link,[":","%"],[""]);
        text = llInsertString(text,index,"http://secondlife.com/app/image/"+llList2String(temp,1)+"/1");
    }                
    while(llSubStringIndex(text,"%SLURL%")!=-1)
    {
        integer index = llSubStringIndex(text,"%SLURL%");
        text = llDeleteSubString(text,index,index+6);
        vector pos = llGetPos();
        text = llInsertString(text,index,"http://slurl.com/secondlife/"+llEscapeURL(llGetRegionName())+"/"+(string)llFloor(pos.x)+"/"+(string)llFloor(pos.y)+"/"+(string)llFloor(pos.z)+"/?title="+llEscapeURL(llList2String(parcelinfo,0)));
    }        
   
    return text;
}

default
{
    state_entry()
    {
        list namecheck = llParseString2List(llGetScriptName(),[" "],[]);
        if (llGetListLength(namecheck) == 2)
        {
            page_num = llList2Integer(namecheck,1);
        }
        else
        {
            page_num = 0;
        }
//        llOwnerSay("Page Num: "+(string)page_num);
//        llOwnerSay("Free Memory: "+(string)llGetFreeMemory()+" bytes");
    }
    
    link_message(integer se, integer n, string str, key id)
    {
        if (n == page_num && id == "11111111-1111-1111-1111-111111111111")
        {
            page_name = str;
            lquery = llGetNotecardLine(page_name,0);
        }
        else if (n == 100000 && str==page_name)
        {
            llMessageLinked(LINK_THIS,100001,page_data,id);
        }            
    }
    
    dataserver(key q, string str)
    {
        if (q == lquery)
        {
            if (str != EOF)
            {
                ++nline;
                page_data+=check_line(str);
                lquery = llGetNotecardLine(page_name,nline);
            }
            else
            {
                llMessageLinked(LINK_THIS,page_num,"","22222222-2222-2222-2222-222222222222");
            }
        }
    }            
}

