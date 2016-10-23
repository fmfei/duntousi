$(function (){
	 $('.visiteds').parent().show();
	 $('a.title').each(function(index, element) {
        $(this).click(function (){
			 $(this).next('div').slideToggle('slow');
			});
    });
	
	$('.yinhangk').each(function (i,e){
		 $(this).click(function (){
			  $(".yinhang").css({"border":"1px solid #ccc"});
			  $('.yinhangk').css({"backgroundImage":"url(image/huidian.png)"});
			  $(this).find("input[type='radio']").attr("checked","checked");
			  $(this).find(".yinhang").css({"border":"1px solid #ff6766"});
			  $(this).css({"backgroundImage":"url(image/judian.png)"});
			 });
		});
	$('.tongtit div').eq(0).addClass('xshi');
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
	$('.xiaoxi li').each(function (i){
		  $(this).click(function (){
			$('.xiaoxi li div').hide();
			$('.xiaoxi li').css({"color":"#4cadda"});
			$(this).css({"color":"#ff6766"});
		    $(this).find('div').css({"display":"block"});
		  });
		});
	$('.xiaoxi li div span.right').click(function (){
		   event.stopPropagation();
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
		       alert('请您填写正确的格式。');
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
	$('input.jkrsubmitser').click(function (e){
		$('form.dkrform input').each(function(index, element) {
			alert($(this).val());
			if($(this).val()==''){
				   alert('请您填写完整信息。');
				   e.preventDefault();
				   return false;
				}
		});
	});
	$.extend({
		   dkryanzheng:function (a,b){
			      $(a).blur(function (){
					  // bs=new RegExp(b,'g');
					   var bools=b.test($(this).val());
					   if(bools==false){
							  alert('请您填写正确的格式。');
							  $(this).val('');
							  $(this).css({"border":"1px solid red"});
						   }else{
							   $(this).css({"border":"1px solid #ccc"});
							   }
					});
			   }
		});
	$.dkryanzheng('input.dkrsj',/^1(3|5|8){1}\d{9}$/);
	$.dkryanzheng('input.dkryx',/^(\w-*\.*)+@(\w-?)+(\.\w{2,})+$/);
	$.dkryanzheng('input.zhucesj',/^1(3|5|8){1}\d{9}$/);
	$('.phangb .listsf').eq(0).css({"display":"block"});
	$('.phangb .title div').each(function(index, element) {
        $(this).click(function (){
			   $('.phangb .title div').removeClass('bord');
			   $(this).addClass('bord');
			   $('.phangb .listsf').css({"display":"none"});
			   $('.phangb .listsf').eq(index).css({"display":"block"});
			});
    });	 
	$('.contens').eq(0).css("display","block");
	$('.titletop a').each(function(index, element) {
        $(this).click(function (){
			   $('.titletop a').removeClass('bor');
			   $(this).addClass('bor');
			   $('.contens').css("display","none");
			   $('.contens').eq(index).css("display","block");
			});
    });
	// $('.zccfmm').blur(function (){
	// 	   if($(this).val()!=$('.zcdlmm').val()){
	// 		    alert('您两次输入密码不同。');
	// 		   $(this).val('');
	// 		   $(this).css({"border":"1px solid red"});
	// 		   return mmcheck=false;
	// 	    }else{
	// 		   $(this).css({"border":"1px solid #ccc"});
	// 		   return mmcheck=true;
	// 		   }
	// 	});
  //   $('input.zzqding').click(function (e){
	 //    $.dkryanzheng('input.zhucesj',/^1(3|5|8){1}\d{9}$/);
	 //    $('.zhuceform input').each(function(index, element) {
		//    if($(this).val()==''||mmcheck==false){
		// 	      alert('请填写完整您的信息。');
		// 		  e.preventDefault();
		// 		  return false;
		// 	   }
		// });
  //   });
  $.get("/footer",function(data){
  	$('.foot').html(data)
  });
  $.get("/nav",function(data){
  	$('.navright').html(data)
  });
});

