//<![CDATA[
//swt_r.gif 原来的图片。
var tips; var theTop = 60/*这是默认高度,越大越往下*/; var old = theTop;
function initFloatTips() {
  tips = document.getElementById('divQQbox');
  moveTips();
};

function moveTips() {
	var tt=50;
	if (window.innerHeight) {
		pos = window.pageYOffset
	}
	else if (document.documentElement && document.documentElement.scrollTop) {
		pos = document.documentElement.scrollTop
	}
	else if (document.body) {
		pos = document.body.scrollTop;
	}
	pos=pos-tips.offsetTop+theTop;
	pos=tips.offsetTop+pos/10;
	
	if (pos < theTop) pos = theTop;
	if (pos != old) {
		tips.style.top = pos+"px";
		tt=10;
	
	}
	old = pos;
	setTimeout(moveTips,tt);
}
//!]]>
initFloatTips();