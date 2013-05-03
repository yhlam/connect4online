var ROW_NUM = 6;
var COL_NUM = 7;
var USER_COLOR = 'red';
var COLOR_TIME = 100;

function move(row, col) {
    var $row = 0;
    color = function() {
        if($row > 0) {
            var last_cell = $('#cell'+($row-1)+col);
            last_cell.css('background-color', 'white');
        }
        var cell = $('#cell'+$row+col);
        cell.css('background-color', USER_COLOR);

        if($row < row) {
            $row++;
            setTimeout(color, COLOR_TIME);
        }
    }

    color();
}

var btns = $("#move-btns .btn");
for(var i=0; i<btns.length; i++) {
    var btn = $(btns[i]);
    btn.click(function(col) {
       return  function() {
        // TODO: Change the row
        var row = 5;
        move(row, col);
       };
    }(i));
}
