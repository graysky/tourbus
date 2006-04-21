var allVersion = navigator.appVersion.split("MSIE")
var ieVersion = parseFloat(allVersion[1])
// PNG fix for IE that stops the flashing during loading. Used explicitly on the noticable PNGs.
// http://homepage.ntlworld.com/bobosola/pnginfo.htm#trouble
function fixPNG(myImage) 
{
	if ((ieVersion >= 5.5) && (ieVersion < 7) && (document.body.filters)) 
    {
		var imgID = (myImage.id) ? "id='" + myImage.id + "' " : "";
	   	var imgClass = (myImage.className) ? "class='" + myImage.className + "' " : "";
	   	var imgTitle = (myImage.title) ? 
		             "title='" + myImage.title  + "' " : "title='" + myImage.alt + "' ";
	   	var imgStyle = "display:inline-block;" + myImage.style.cssText
	   	var strNewHTML = "<span " + imgID + imgClass + imgTitle
                  + " style=\"" + "width:" + myImage.width 
                  + "px; height:" + myImage.height 
                  + "px;" + imgStyle + ";"
                  + "filter:progid:DXImageTransform.Microsoft.AlphaImageLoader"
                  + "(src=\'" + myImage.src + "\', sizingMethod='scale');\"></span>"
	   	myImage.outerHTML = strNewHTML	  
    }
}
