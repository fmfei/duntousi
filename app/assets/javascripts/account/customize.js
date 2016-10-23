$(function (){
	 //   $('a.title').eq(0).next('div').css({'display':'block'});
	 $('.visiteds').parent().show();
	 $('a.title').each(function(index, element) {
	 	$(this).click(function (){
	 		$(this).next('div').slideToggle('slow');
	 	});
	 });

	 // $('.tongtit div').eq(0).addClass('xshi');
	 $('.tongtit div').each(function(index, element) {
	 	$('.contents').eq(0).css("display","block");
	 	$(this).click(function (){
	 		$('.tongtit div').removeClass('xshi');
	 		$('.tongtit div').eq(index).addClass('xshi');
	 		$('.contents').hide('slow');
	 		$('.contents').eq(index).show('slow');
	 	});
	 });
	 $('.xiaoxi li div').eq(0).css('display','block');
	 $('.contents').each(function(){
	 	$(this).find('.xiaoxi li').eq(0).css('color','#ff6766');
	 	$(this).find('.xiaoxi li').eq(0).find('div').css('display','block');
	 });
	 $('.xiaoxi li .display_nb').each(function (i){
	 	$(this).click(function (){
	 		$('.xiaoxi li div').hide();
	 		$('.xiaoxi li').css({"color":"#4cadda"});
	 		$(this).parent().css({"color":"#ff6766"});
	 		$(this).parent().find('div').css({"display":"block"});
	 	});
	 });
	 $('.xiaoxi li div .right').click(function (){
	 	$(this).parent().css({'display':'none'});
	 	$(this).parents('li').css({"color":"#4cadda"});
	 });
	 sjrzyz=function (a,b){
	 	if(b==undefined){
	 		b="^1{1}(3|5|8){1}[0-9]{9}$";
	 	}else{
	 		b=b;
	 	};
	 	var telval=$(a).val();
	 	var patt=new RegExp(b,"g");
	 	var booltel=patt.test(telval);
	 	if(booltel==false){
	 		alert('请您填写正确的手机号码。');
	 		$(a).css({'border':'1px solid red'});
	 		$(a).val('');
	 		return false;
	 	}else{
	 		$(a).css({'border':'1px solid #ccc'});
	 	}
	 }
	 $('.sjyzforms .tel').blur(function (){
	 	sjrzyz('.sjyzform .tel');
	 });
	 $('form.sjyzforms').submit(function (){
	 	if($('.sjyzform .tel').val()==''){
	 		$('.sjyzform .tel').css({'border':'1px solid red'});
	 		return false;
	 	}
	 	sjrzyz('.sjyzform .tel');
	 });
	 $('.grzlform input.grzlsj').blur(function (){
	 	grzlsjzhi=$('input.grzlsj').val();
	 	var sjyz=/^1{1}(3|5|8){1}[0-9]{9}$/.test(grzlsjzhi);
	 	if(!sjyz){
	 		alert('请填写正确的手机号码。');
	 		$('input.grzlsj').val('');
				//$('input.grzlsj').focus();
				$('input.grzlsj').css({'border':'1px solid red'});
				return false;
			}else{
				$('input.grzlsj').css({'border':'1px solid #ccc'});
			}
		});
	 $('.grzlform input.grzldh').blur(function (){
	 	grzldhzhi=$('input.grzldh').val();
	 	var dhyz=/^0\d{2,3}-?\d{7,8}$/.test(grzldhzhi);
	 	if(!dhyz){
	 		alert('请填写正确的电话号码。');
	 		$('input.grzldh').val('');
				//$('input.grzldh').focus();
				$('input.grzldh').css({'border':'1px solid red'});
				return false;
			}else{
				$('input.grzldh').css({'border':'1px solid #ccc'});
			}
		});
	 $('form.grzlform').submit(function (){
	 	$('.grzlform input').each(function (i,e){
	 		if($(this).val()==''){
	 			alert('请填写完整，谢谢。');
	 			return false;
	 		}
	 	});
	 });
	 $('.fileup').hide();
	 $('.touxiangd').click(function (){
	 	$('.modals').css('display','block');
	 	$('.hqyzmers').click(function (){
	 		$('input.fileup').trigger('click');
	 	});
	 });
	 $('.hqyzreset').click(function (){
	 	$('input.fileup').val('');
	 	$('.modals').css('display','none');
	 	return false;
	 });
	 $('.hqyzm').click(function (){
	 	$('.modals').css('display','none');
	 });
	 $('.touzilist .title .right').click(function (){
	 	$('.touzilist .lister').slideToggle();
	 });

	 $('.txxqtabcon').css({"display":"none"});
	 $('.txxqtabcon').eq(0).css({"display":"block"});
	 $('.txxqtab a').each(function (i,e){
	 	$('.txxqtab a').eq(0).css({"color":"#000","borderBottom":"2px solid #ff6666"});
	 	$(this).click(function (){
	 		$('.txxqtab a').css({"color":"#9c9d9d","borderBottom":"0"});
	 		$(this).css({"color":"#000","borderBottom":"2px solid #ff6666"});
	 		$('.txxqtabcon').css({"display":"none"});
	 		$('.txxqtabcon').eq(i).css('display','block');
	 	});
	 });

	 $('.alert .close').click(function(){
	 	 $(this).parent().hide();
	 })

	  $('form').validate();

	});
(function( factory ) {
	if ( typeof define === "function" && define.amd ) {
		define( ["jquery", "../jquery.validate"], factory );
	} else {
		factory( jQuery );
	}
}(function( $ ) {

/*
 * Translated default messages for the jQuery validation plugin.
 * Locale: ZH (Chinese, 中文 (Zhōngwén), 汉语, 漢語)
 */
$.extend($.validator.messages, {
	required: "必须填写",
	remote: "请修正此栏位",
	email: "请输入有效的电子邮件",
	url: "请输入有效的网址",
	date: "请输入有效的日期",
	dateISO: "请输入有效的日期 (YYYY-MM-DD)",
	number: "请输入正确的数字",
	digits: "只可输入数字",
	creditcard: "请输入有效的信用卡号码",
	equalTo: "你的输入不相同",
	extension: "请输入有效的后缀",
	maxlength: $.validator.format("最多 {0} 个字"),
	minlength: $.validator.format("最少 {0} 个字"),
	rangelength: $.validator.format("请输入长度为 {0} 至 {1} 之间的字串"),
	range: $.validator.format("请输入 {0} 至 {1} 之间的数值"),
	max: $.validator.format("请输入不大于 {0} 的数值"),
	min: $.validator.format("请输入不小于 {0} 的数值")
});
	// 页面中的头与尾的实现
	$.ajax({
	    url: "/home/basic_info_json",
	    dataType: 'json',
	    success: function (data) {
	        $('title').text(data.company_name);
	        $('.phone400').text(data.phone400);
	        $('.qq_group').text(data.qq_group);
	        $('.serve_time').text(' 服务时间：' + data.serve_time);
	        // $('.prize_register').text(data.prize_register);
	        $('.prize_register').text('30元红包');
	        // $('.add1').attr('onclick', "javascript:window.location.href='/campaigns/september'");
	        // $('.add2').attr('onclick', "javascript:window.location.href='/campaigns/september'");
	        $('.prize_first').text('50元');
	        $('.promotion_ratio').text(data.promotion_ratio);
	        $('.qq_group').text(data.qq_group);
	        if (data.username.length > 0) {
	            $('#username').text(data.username);
	            $('#hello').show();
	        } else {
	            $('.sign').show();
	        }
	    }
	});

}));