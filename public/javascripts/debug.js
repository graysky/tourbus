// Show printf-like debug statements inside FireBug -- better than alerts!
// Usage: printfire("whatever") 
// http://www.joehewitt.com/software/firebug/faq.php
function printfire()
{
    if (document.createEvent)
    {
        printfire.args = arguments;
        var ev = document.createEvent("Events");
        ev.initEvent("printfire", false, true);
        dispatchEvent(ev);
    }
}