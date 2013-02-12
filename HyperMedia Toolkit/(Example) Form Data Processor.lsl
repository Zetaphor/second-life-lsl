list data;
default
{
    link_message(integer s, integer n, string str, key id)
    {
        if (n==600000)
        {
            llOwnerSay("Recieved POST data from a form");
            data = llParseString2List(str,["&"],[""]);
            integer i;
            for (i=0; i<llGetListLength(data); i++)
            {
                string temp_string = llList2String(data,i);
                list temp = llParseString2List(temp_string,["="],[""]);
                llOwnerSay("Field Name: "+llUnescapeURL(llList2String(temp,0))+" Data: "+llUnescapeURL(llList2String(temp,1)));
            }
        }
    }            
}
