var main = function() {
	var x = 1;
	var obj = new Object();
	var masteriparr = [];
	var workeriparr = [];
	$('#addbutton').click(function() {
		
		x += 1;
		$('.tbodyclass').append("<tr style='height:50px' id=x>" +
				"<td>" +
				"<select class='form-control selectpicker' id='"+x+"select'>" +
				"<option>Master</option>" +
				"<option>Worker</option>" +
				"</select>" +
				"</td>" +
				"<td><input class='form-control' id='"+x+"ipaddress' placeholder='IP Address' style='text-align:center;'></td>" +				
				"<td><input class='form-control' id='"+x+"sshport' placeholder='SSH Port' style='text-align:center;'></td>" +
				"<td><input class='form-control' id='"+x+"interface' placeholder='Interface' style='text-align:center;'></td>" +						
				"<td><input class='form-control' id='"+x+"password' placeholder='Password' style='text-align:center;'></td>" +							
				"</tr>");
		
		
	});
	
	$('#install-button').click(function() {
		
				
		var i=1;
		for(i; i <= x; i++) {
			var t = "select[id="+i+"select] option:selected";			
			var ipt = '#'+i+'ipaddress';
			//var comtype=$('t option:selected').text();
			var comtype=$(t).text();
			//alert(comtype);
			if(comtype=="Master") {
				masteriparr.push($(ipt).val());
			} else {
				workeriparr.push($(ipt).val());
			}
			
		}
			
		
		obj.interfaceval=$('#1interface').val();		
		obj.passwordval=$('#1password').val();
		obj.sshportval=$('#1sshport').val();
		obj.masteriparr=masteriparr;
		obj.workeriparr=workeriparr;
		
		var jsonstr = JSON.stringify(obj);
		
		$.ajax({
			type: 'POST',
			crossOrigin: true,
			url: "http://localhost:9000/",
			data: {data: jsonstr},
			success: function(e) {
				alert(e);
			}
		});
		
	});
	
};



	
$(document).ready(main);
