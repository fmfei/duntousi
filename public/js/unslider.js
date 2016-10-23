$(function(){
	unslider = $('.xbanner').unslider(),
	$('.unslider-arrow').click(function() {
        var fn = this.className.split(' ')[1];
        unslider.data('unslider')[fn]();
    });
	unslider2 = $('.xbanner2').unslider(),
	$('.unslider-arrow2').click(function() {
        var fn = this.className.split(' ')[1];
        unslider2.data('unslider')[fn]();
    });
	unslider3 = $('.xbanner3').unslider(),
	$('.unslider-arrow3').click(function() {
        var fn = this.className.split(' ')[1];
        unslider3.data('unslider')[fn]();
    });
	unslider4 = $('.xbanner4').unslider(),
	$('.unslider-arrow4').click(function() {
        var fn = this.className.split(' ')[1];
        unslider4.data('unslider')[fn]();
    });
	unslider5 = $('.xbanner5').unslider(),
	$('.unslider-arrow5').click(function() {
        var fn = this.className.split(' ')[1];
        unslider5.data('unslider')[fn]();
    });
	unslider6 = $('.xbanner6').unslider(),
	$('.unslider-arrow6').click(function() {
        var fn = this.className.split(' ')[1];
        unslider6.data('unslider')[fn]();
    });
});