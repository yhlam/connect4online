var ROW_NUM = 6;
var COL_NUM = 7;
var USER_COLOR = 'red';
var USER2_COLOR= 'yellow';
var EMPTY_COLOR= 'white';
var CONTINUE ='cont';
var TIE ='tie';
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
		player=='1'?state[row*(COL_NUM)+col]=1:state[row*(COL_NUM)+col*1]=2;
        
		if($row < row) {
            $row++;
            setTimeout(color, COLOR_TIME);
        }
    }

    color();
}


function disable_buttons(){
	var btns = $("#move-btns .btn");
	for(var i=0; i<btns.length; i++){
			var btn= $(btns[i]);
			btn.attr('disabled', 'disabled');
			btn.addClass('disabled');
		}
}

function resume_buttons(){
	var btns = $("#move-btns .btn");
	for(var i=0; i<btns.length; i++){
		var btn= $(btns[i]);
		btn.removeAttr('disabled');
		btn.removeClass('disabled');
	}
}

function available_row(col){
	for (var row=ROW_NUM-1; row>=0; row--){	
		if(state[row*(COL_NUM)+col]==0){
			return row;
		}
	}
	//disable button if no empty row
	var btn = $('#btn'+col);
	btn.attr('disabled', 'disabled');
	btn.addClass('disabled');
}



var btns = $("#move-btns .btn");
for(var i=0; i<btns.length; i++) {
    var btn = $(btns[i]);
    btn.click(function(col) {
       return  function() {

		disable_buttons();
	   
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
				var next_move =success[0];
				var move_row = success[1];
				var move_col = success[2];
				
				if (next_move == CONTINUE){

					move(move_row,move_col,'2');
					resume_buttons();
				}else if (next_move == TIE){
					var console=$('#console h1:first');
					console.text("Draw Game!");
				}else{				
					if(move_row && move_col){
					move(move_row,move_col,'2');}

					var console=$('#console h1:first');
					console.text("You "+next_move+"!!");
				}

				
			},
			error: function(error){
				alert("Error occurs!"+error);
			}
		});

       };
    }(i));
}
