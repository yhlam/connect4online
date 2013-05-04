var ROW_NUM = 6;
var COL_NUM = 7;
var USER_COLOR = 'red';
var USER2_COLOR= 'yellow';
var EMPTY_COLOR= 'white';
var COLOR_TIME = 100;
var state = new Array(ROW_NUM*COL_NUM);
//Init the state
for (var i=0;i<ROW_NUM*COL_NUM;i++){
	state[i]=0;
}

function move(row, col,player) {
    var $row = 0;
    color = function() {
        if($row > 0) {
            var last_cell = $('#cell'+($row-1)+col);
            last_cell.css('background-color', 'white');
        }
        var cell = $('#cell'+$row+col);
		
        player=='1'?cell.css('background-color', USER_COLOR):cell.css('background-color', USER2_COLOR);
		player=='1'?state[row*(COL_NUM)+col]=1:state[row*(COL_NUM)+col]=2;
        
		if($row < row) {
            $row++;
            setTimeout(color, COLOR_TIME);
        }
    }

    color();
}

function available_row(col){
	for (var row=ROW_NUM-1; row>=0; row--){	
		if(state[row*(COL_NUM)+col]==0){
			return row;
		}
	}
	//disable button if no empty row
	var btn = $('#btn'+col);
	btn.addClass('disabled');
}

var btns = $("#move-btns .btn");
for(var i=0; i<btns.length; i++) {
    var btn = $(btns[i]);
    btn.click(function(col) {
       return  function() {
		for(var j=0; j<btns.length; j++){
			var button= $(btns[j]);
			button.addClass('disabled');
		}
	   
		var next_row = available_row(col);
		
        move(next_row, col,'1');
		var state_string=state.join('');
		$.ajax({
			type: 'POST',
			url: './ai.pl',
			data: {
				'state': state_string,
				'last_row': next_row,
				'last_col': col,
			},
			success: function(success){
				var success=success.split(" ");
				var result =success[0];
				var updated_state=success[1];
				for (var k=0;k<ROW_NUM*COL_NUM;k++){
					if(updated_state.charAt(k)!=state[k]){
						move(Math.floor(k/COL_NUM),k%COL_NUM,'2');
						for(var j=0; j<btns.length; j++){
							var button= $(btns[j]);
							button.removeClass('disabled');
						}
					}
				}
			
			},
			error: function(error){
				alert("Error occurs!"+error);
			}
		});

       };
    }(i));
}
