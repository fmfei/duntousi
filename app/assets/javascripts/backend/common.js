$(function (){
	// 全选
	$("#ck_all").click(function() {
		$("input[type='checkbox']").prop("checked", this.checked);
	})

})
// 实名认证
function auth_realname_pass(user_id, pass) {
	$.get("auth_realname_pass?id=" + user_id + "&pass=" + pass,
		function(data){
      alert(data["data"]);
      window.location.reload();
    });
}

function set_back(path) {
	var back_path = $(".back_btn").attr("href");
	if(back_path == "javascript:history.back()") {
		$(".back_btn").attr("href", path);
	}
}