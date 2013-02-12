/*
Link Numbers
500000 - Startup to page read scripts to read all notecards
500001 - Returned from read scripts to indicate notecard read
100000 - Page request (string pagename, key HTTPResponse ID)
100001 - Sent back from page request to check against current ID, str contains formatted page data
*/
key current_response;
string url;
string gurl; //Gateway URL
string current_page;
integer readystates;
string formr;
string errorp;
list uservars;

// This wraps the html you want to display so that it will be shown from links 
// made with build_url
string build_response(string body)
{
    return "function init() {document.getElementsByTagName('body')[0].innerHTML='" + body + "';}";
}

string check_tags(string text)
{
    while(llSubStringIndex(text,"%BURL%")!=-1)
    {
        integer index = llSubStringIndex(text,"%BURL%");
        text = llDeleteSubString(text,index,index+5);
        text = llInsertString(text,index,gurl);
    }
    while(llSubStringIndex(text,"%URL%")!=-1)
    {
        integer index = llSubStringIndex(text,"%URL%");
        text = llDeleteSubString(text,index,index+4);
        text = llInsertString(text,index,url);
    }
    integer i;
    integer count = fncStrideCount(uservars,2);
    for (i=0; i<count; i++) //Uservars replace
    {
        integer index;
        list var = fncGetStride(uservars, i, 2);
        while (llSubStringIndex(text,"%"+llList2String(var,0)+"%")!=-1)
        {
            index = llSubStringIndex(text,"%"+llList2String(var,0)+"%");
            text = llDeleteSubString(text,index,index+llStringLength(llList2String(var,0))+1);
            text = llInsertString(text,index,llList2String(var,1));         
        }
    } 
    
    if(llSubStringIndex(text,"%FORMR:")!=-1)
    {
        integer count=1;
        integer index = llSubStringIndex(text,"%FORMR:");
        integer found;
        string check;
        integer end_index;
        while (found==FALSE)
        {
            check = llGetSubString(text,index+count,index+count);
            if (check=="%"){found=TRUE;end_index = index+count;}
            count++;
        }
        formr = llGetSubString(text,index,end_index);
        list temp = llParseString2List(formr,[":","%"],[""]);
        formr = llList2String(temp,1);
        text = llDeleteSubString(text,index,end_index);
    }
    else
    {
        formr = "";
    }
    return text;
}

// Find a Stride within a List (returns stride index, and item subindex)
list fncFindStride(list lstSource, list lstItem, integer intStride)
{
  integer intListIndex = llListFindList(lstSource, lstItem);
  
  if (intListIndex == -1) { return [-1, -1]; }
  
  integer intStrideIndex = intListIndex / intStride;
  integer intSubIndex = intListIndex % intStride;
  
  return [intStrideIndex, intSubIndex];
}

// Returns number of Strides in a List
integer fncStrideCount(list lstSource, integer intStride)
{
  return llGetListLength(lstSource) / intStride;
}

// Replace a Stride in a List
list fncReplaceStride(list lstSource, list lstStride, integer intIndex, integer intStride)
{
  integer intNumStrides = fncStrideCount(lstSource, intStride);
  
  if (llGetListLength(lstStride) != intStride) { return lstSource; }
  
  if (intNumStrides != 0 && intIndex < intNumStrides)
  {
    integer intOffset = intIndex * intStride;
    return llListReplaceList(lstSource, lstStride, intOffset, intOffset + (intStride - 1));
  }
  return lstSource;
}

// Deletes a Stride from a List
list fncDeleteStride(list lstSource, integer intIndex, integer intStride)
{
  integer intNumStrides = fncStrideCount(lstSource, intStride);
  
  if (intNumStrides != 0 && intIndex < intNumStrides)
  {
    integer intOffset = intIndex * intStride;
    return llDeleteSubList(lstSource, intOffset, intOffset + (intStride - 1));
  }
  return lstSource;
}

// Returns a Stride from a List
list fncGetStride(list lstSource, integer intIndex, integer intStride)
{
  integer intNumStrides = fncStrideCount(lstSource, intStride);
  
  if (intNumStrides != 0 && intIndex < intNumStrides)
  {
    integer intOffset = intIndex * intStride;
    return llList2List(lstSource, intOffset, intOffset + (intStride - 1));
  }
  return [];
}


default
{
    state_entry()
    {
        llOwnerSay("Resetting scripts");
        llSetScriptState("_Storage Controller",TRUE);
        llSleep(1.0);        
        llSetScriptState("_Gateway Controller",TRUE);        
        llSleep(1.0);
        llResetOtherScript("_Storage Controller");
        llSleep(1.0);
        llMessageLinked(LINK_THIS,510000,"","");
        llSleep(1.0);        
        integer i;
        integer storcheck = llGetInventoryNumber(INVENTORY_SCRIPT);
        for (i=0; i<storcheck; i++)
        {
            if (llListFindList(llParseString2List(llGetInventoryName(INVENTORY_SCRIPT,i),[" "],[]),["~StorageObject"]) != -1)
            {
                llResetOtherScript(llGetInventoryName(INVENTORY_SCRIPT,i));
                llSetScriptState(llGetInventoryName(INVENTORY_SCRIPT,i),TRUE);
            }
        }        
        state startup;
    }
}

state shutdown
{
    state_entry()
    {
        llOwnerSay("Shutting Down");
        llSetScriptState("_Gateway Controller",FALSE);
        llSleep(1.0);
        llSetScriptState("_Storage Controller",FALSE);
        llSleep(1.0);        
        integer i;
        integer storcheck = llGetInventoryNumber(INVENTORY_SCRIPT);
        llResetOtherScript("_Gateway Controller");
        llSleep(1.0);        
        for (i=0; i<storcheck; i++)
        {
            if (llListFindList(llParseString2List(llGetInventoryName(INVENTORY_SCRIPT,i),[" "],[]),["~StorageObject"]) != -1)
            {
                llSetScriptState(llGetInventoryName(INVENTORY_SCRIPT,i),FALSE);
                llSleep(1.0);                
                llResetOtherScript(llGetInventoryName(INVENTORY_SCRIPT,i));
                llSleep(1.0);                                
            }
        }
        llOwnerSay("Shutdown complete");
    }
    
    link_message(integer se, integer n, string str, key id)
    {
        if (n == 1000001)
        {
            llResetScript();
        }
    }
}

state startup
{
    state_entry()
    {
        llOwnerSay("Starting up...");
        readystates = 0;
        llMessageLinked(LINK_THIS,500000,"","");
    }
    
    link_message(integer se, integer num, string str, key id)
    {
        if (num == 500001)
        {
            errorp = str;
            ++readystates;
            if (readystates == 2)
            {
                state running;
            }
        }
        else if (num == 200000)
        {
            gurl = str;
            ++readystates;
            if (readystates == 2)
            {
                state running;
            }
        }
    }
}

state running
{
    state_entry()
    {
        llOwnerSay("Requesting Server URL...");
        llRequestURL();
    }
    
    http_request(key id, string method, string body)
    {
        if (method == URL_REQUEST_GRANTED)
        {
            url = body;
            llMessageLinked(LINK_THIS,200001,body,"");            
        }
        else if (method == URL_REQUEST_DENIED)
        {
            llSay(0, "Something went wrong, no url. " + body);
        }
        else if (method == "GET")
        {
            current_response = id;
            list path = llParseString2List(llGetHTTPHeader(id,"x-path-info"),["/"],[]);            
            if (llGetListLength(path)!=0)
            {
                if (llList2String(path,0) == "link")
                {
                    current_page = llList2String(path,1);
                    llMessageLinked(LINK_THIS,100000,llList2String(path,1),id);
                }                    
            }
            else
            {
                current_page = "index";                
                llMessageLinked(LINK_THIS,100000,"index",id);
            }
        }
        else if (method=="POST")
        {
            current_response = id;
            string response = body;
            while (llSubStringIndex(response,"+")!=-1)
            {
                integer index = llSubStringIndex(response,"+");
                response = llDeleteSubString(response,index,index);
                response = llInsertString(response,index,"%20");
            }
            llMessageLinked(LINK_SET,600000,response,"");
            if (formr == "")
            {           
                llMessageLinked(LINK_THIS,700000,current_page,"");
            }
            else
            {
                current_page = formr;                
                llMessageLinked(LINK_THIS,700000,formr,"");
            }                
        }
        else
        {
            llHTTPResponse(id,405,"Unsupported Method");
        }
    }
    
    link_message(integer se, integer num, string str, key id)
    {
        if (num == 100001)
        {
            if (id == current_response)
            {
                if (str!="404")
                {
                    str = check_tags(str);
                    llHTTPResponse(id,200,build_response(str));
                }
                else
                {
                    llMessageLinked(LINK_THIS,700000,errorp,"");
                }
            }
        }
        else if (num == 800000)
        {
            list data = llParseString2List(str,["^"],[]);
            list indx = fncFindStride(uservars, [llList2String(data,0)], 2);
            if (llList2Integer(indx,0)!=-1)
            {
                if (llList2Integer(indx,1)==0)
                {
                    //llOwnerSay("Updated! "+llList2String(data,0)+": "+llList2String(data,1));
                    uservars = fncReplaceStride(uservars, [llList2String(data,0),llList2String(data,1)], llList2Integer(indx,0), 2);
                    //llOwnerSay("Results: "+llDumpList2String(uservars,","));
                }
            }
            else
            {
                //llOwnerSay("Created! "+llList2String(data,0)+": "+llList2String(data,1));                
                uservars += [llList2String(data,0),llList2String(data,1)];
                //llOwnerSay("Results: "+llDumpList2String(uservars,","));                
            }
        }
        else if (num == 800001)
        {
            //llOwnerSay("Delete Stride");            
            list indx = fncFindStride(uservars, [str], 2);            
            uservars = fncDeleteStride(uservars, llList2Integer(indx,0), 3);
            //llOwnerSay("Result: "+llDumpList2String(uservars,","));
        }
        else if (num == 1000000)
        {
            state shutdown;
        }
    }
}
