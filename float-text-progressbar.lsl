string progress;
string empty = "□";
string filled = "■";
integer value;
progressbar(float percent)
{
    integer x;
    integer length = llFloor(percent/10);
    while (x!=length)
    {
        progress+=filled;
        x++;
    }
    while (x!=10)
    {
        progress+=empty;
        x++;
    }
    integer dpercent = llFloor(percent);
    llSetText((string)dpercent+"%\n"+progress,<1,1,1>,1);
}

default
{
    touch_start(integer total_number)
    {
        llSetText("",<1,1,1>,1);
        value=0;
        llSetTimerEvent(0.1);
    }

    timer()
    {
        value++;
        if (value<101)
        {
            progressbar(value);
        }
        else
        {
            llSay(0,"Completed!");
            llSetTimerEvent(0);
        }
    }
}
