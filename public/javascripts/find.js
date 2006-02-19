function confirm_location(event)
{
	$('current_location').innerHTML = $('new_location').value;
	$('current_radius').innerHTML = "+ " + $('new_radius').value + " miles";
	
	set_location_radius($('new_location').value, $('new_radius').value);
	
	Tooltip.toggle($('change_location_link'), event);
}

function cancel_location(event)
{
	Tooltip.toggle($('change_location_link'), event);
}

function reset_location(loc, rad)
{
	$('new_location').value = loc;
	$('new_radius').value = rad;
}
		
function on_search()
{
	// Nothing to do
}

