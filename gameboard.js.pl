#!/usr/local/bin/perl5 -w

use CGI qw(:standard);
use multiplayer;

$mode = param("mode");
$user = param("user");

if($mode eq "single") {
    $user1 = $user;
    $user2 = "Computer";
    $ajax_url = "ai.pl";
    $ajax_data = <<DATA;
        'state': state_string,
        'last_row': next_row,
        'last_col': col,
DATA
    $ajax_success = <<SUCCESS;
        var success=success.split(" ");
        var next_move =success[0];
        var move_row = success[1];
        var move_col = success[2];
        
        if (next_move == CONTINUE){

                move(move_row,move_col,'2');
                resume_buttons();
        }else if (next_move == TIE){
                var console=\$('#console h1:first');
                console.text("Draw Game!");
        }else{				
                if(move_row && move_col){
                move(move_row,move_col,'2');}

                var console=\$('#console h1:first');
                console.text("You "+next_move+"!!");
        }
SUCCESS
}
else {
    $ajax_url = "updatestate.pl";
    $ajax_data = <<DATA;
        'gameid': gameid,
        'role': role,
        'state': state.join(""),
        'user': user,
        'row': next_row,
        'col': col,
DATA
    $ajax_success = <<SUCCESS;
        if (success == 'win'){
                var console=\$('#console h1:first');
                console.text("You win!");
                disable_buttons();
        }
        else if(success == TIE) {
                var console=\$('#console h1:first');
                console.text("Draw Game!");
                disable_buttons();
        }
        else {
            resume_buttons();
        }
SUCCESS
    if($mode eq "create") {
        $user1 = $user;
        $user2 = "";
    }
    else {
        $user1 = "";
        $user2 = $user;
    }
}

print "Content-Type: application/javascript\n";
print <<COMMON;

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
    var \$row = 0;
    color = function() {
        if(\$row > 0) {
            var last_cell = \$('#cell'+(\$row-1)+col);
            last_cell.css('background-color', 'white');
        }
        var cell = \$('#cell'+\$row+col);
		
        player=='1'?cell.css('background-color', USER_COLOR):cell.css('background-color', USER2_COLOR);
        player=='1'?state[row*(COL_NUM)+col]=1:state[row*(COL_NUM)+col*1]=2;

        //disable button if no empty row
        var btn = \$('#btn'+col);
        if (row== 0){
            btn.attr('disabled', 'disabled');
            btn.addClass('disabled');
            btn.hide();
        }
        
        if(\$row < row) {
            \$row++;
            setTimeout(color, COLOR_TIME);
        }
    }

    color();
}


function disable_buttons(){
	var btns = \$("#move-btns .btn");
	for(var i=0; i<btns.length; i++){
			var btn= \$(btns[i]);
			btn.attr('disabled', 'disabled');
			btn.addClass('disabled');
		}
}

function resume_buttons(){
	var btns = \$("#move-btns .btn");
	for(var i=0; i<btns.length; i++){
		var btn= \$(btns[i]);
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
}



var btns = \$("#move-btns .btn");
for(var i=0; i<btns.length; i++) {
    var btn = \$(btns[i]);
    btn.click(function(col) {
       return  function() {

		disable_buttons();
	   
		var next_row = available_row(col);
		
        move(next_row, col,role);
		var state_string=state.join('');
		\$.ajax({
			type: 'POST',
			url: '$ajax_url',
			data: {
                                $ajax_data
			},
			success: function(success){
			        $ajax_success	
			},
			error: function(error){
				alert("Error occurs!"+error);
			}
		});

       };
    }(i));
}

\$('#user1').html("$user1");
\$('#user2').html("$user2");

COMMON

if($mode eq "single") {
    print "var role='1';\n";
}
else {
    print "var user = '$user';\n";

    if($mode eq "create") {
        $gameid = createGame($user);
        print <<CREATE;
var gameid = "$gameid";
var role = "1";
var hideModal = true;
\$('#modal-body').html("<h4>Please give this code to your friend</h4><br/>" + 
    "<div style='text-align:center'><h1>$gameid</h1></div>" +
    "<div style='text-align:center'><img src='loading.gif' />Waiting another user join this game.</div>");
\$('#modal').modal('show');
CREATE
    }
    elsif($mode eq "join") {
        print <<JOIN;
var role = "2";
var gameid="";
var hideModal = false;
\$('#modal-body').html("<h4>Please enter the game code:</h4><br/>" + 
    "<div class='form-inline'>" +
        "<div id='gameid-control' class='control-group' style='text-align:center'>" +
        "<input id='gameid-input' type='text' class='input' style='margin-right:10px' placeholder='Game Code'>" +
        "<span id='err-msg' class='help-inline'>Invalid game code.</span>" + 
        "</div>" +
        "<button id='gameid-btn' type='submit' class='btn btn-large btn-primary pull-right' style='margin-right:30px'>Submit</button>" +
    "</div>");
\$('#modal').modal('show');

\$('#gameid-btn').click(function() {
    gameid = \$('#gameid-input').val();
    if(!gameid) {
        \$('#gameid-control').addClass('error');
        \$('#err-msg').css('display', 'inline');
        return;
    }
    \$.ajax({
        type: 'POST',
        url: 'joingame.pl',
        data: {
            gameid: gameid,
            user: user
        },
        success: function(success){
            if(success) {
                \$('#user1').html(success);
                \$('#modal').modal('hide');
            }
            else {
                \$('#gameid-control').addClass('error');
                \$('#err-msg').css('display', 'inline');
            }
        },
        error: function(error){
            \$('#gameid-control').addClass('error');
            \$('#err-msg').css('display', 'inline');
        }
    });

});
JOIN
    }
    print <<MULTI;
var timer = setInterval(function() {
    \$.ajax({
        type: 'POST',
        url: 'getstate.pl',
        data: {
            gameid: gameid,
            role: role,
            state: state.join('')
        },
        success: function(success){
            if(success) {
                var success=success.split(" ");
                var opponent = success[0];
                var result = success[1];
                var r = parseInt(success[2]);
                var c = parseInt(success[3]);

                if(hideModal) {
                    \$('#modal').modal('hide');
                    \$('#user2').html(opponent);
                    hideModal = false;
                }

                if(role == '1') {
                    move(r, c, '2');
                }
                else {
                    move(r, c, '1');
                }

                if (result == CONTINUE){
                    resume_buttons();
                }else if (result == TIE){
                    var console=\$('#console h1:first');
                    console.text("Draw Game!");
                }else{				
                    var console=\$('#console h1:first');
                    console.text("You "+result+"!!");
                }
            }
        },
        error: function(error){
        }
    });

}, 1000);
MULTI
}
