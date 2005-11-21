// Helper functions for dealing with google maps.
// Depends on the google maps API file.
// Should only be included once because of the array of markers, so only
// reference this file in the gmaps_header helper.

var markerMap = new Object();

function createMarker(point, html, id)
{
	var marker = new GMarker(point);
	
	GEvent.addListener(marker, "click", function() {
	    marker.openInfoWindowHtml(html);
	});
	
	if (id) {
		// Register this market and HTML window for use by other javascript events
		markerMap[id] = [marker, html];
	}
	
	return marker;
}

function showInfoWindow(id)
{
	markerMap[id][0].openInfoWindowHtml(markerMap[id][1]);
}