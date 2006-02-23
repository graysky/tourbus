function adjust_bio_height(force)
{
	var logo_height = parseInt(Element.getHeight('logo'));
	var bio_height = parseInt($('band_bio').offsetHeight);
	if ((force || logo_height > bio_height) && logo_height > 140) {
		$('band_bio').style.height = logo_height;
	}
	else if (force && logo_height < 140) {
		$('band_bio').style.height = 140;
	}
}

function finish_image_upload(path)
{
	new Effect.Fade('band_logo_select');
	Element.hide('logo_indicator');
	$('logo_container').innerHTML = '';
	var img = document.createElement("IMG");
	img.src = path;
	img.id = 'logo';
	$('logo_container').appendChild(img);
	adjust_bio_height(true);
}
