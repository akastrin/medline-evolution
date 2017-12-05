$(function(){
	$('button').click(function(){
		var user = $('#foo').val();
		var pass = $('#foo').val();
		$.ajax({
			url: '/signUp',
			data: $('form').serialize(),
			type: 'POST',
			success: function(response){
				console.log(response);
			},
			error: function(error){
				console.log(error);
			}
		});
	});
});
