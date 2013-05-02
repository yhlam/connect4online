$COL_NUM = 7;
$ROW_NUM = 6;
$CONNECT = 4;

$EMPTY = "0";

# Parse a state string to a list
# 
# Parameter:
#   $state_str: State of the game board in string
#               0 repersents empty
#               1 repersents user 1
#               2 repersents user 2
# 
# Return:
#   @state: a state list
# 
# Example:
#       col 0 1 2 3 4 5 6
#   --------------------
#   row 0 : 0 0 0 0 0 0 0
#   row 1 : 1 0 0 2 0 0 0
#   row 2 : 2 0 2 1 0 0 0
#   row 3 : 1 2 1 1 0 0 0
#   row 4 : 1 2 1 1 0 1 0
#   row 5 : 1 1 1 2 2 1 2
#
#   The state string is the values in row 0, row 1, ..., row 5.
#   The state string of the above game board:
#       "000000010020002021000121100012110101112212"
sub parse_state {
    my($state_str) = @_;
    my @state = split(//, $state_str);
    return @state;
}


# Convert the state list to a state string
#
# Parameter:
#   @state: the state list of the game board state
#
# Return:
#   $state_str: a string repersent the state of the game board
sub format_state {
    my $state_str = join("", @_);
    return $state_str;
}


# Check if it is valid to put the have a move in the given column
#
# Parameters:
#   @state: State of the game
#   $col: Column of the move
#
# Return:
#   1 if it is valid; Otherwise 0
sub valid_move {
    my $col = pop(@_);
    my @state = @_;
    my $value = $state[$col];
    my $valid = $value eq $EMPTY;
    return $valid;
}


# Add a move of the given column and user
#
# Parameters:
#   @state: State of the game
#   $user: User of the move
#   $col: Column of the move
#
# Return:
#   $row: Row of the move
#   @new_state: The new state after the move
sub move {
    my $col = pop(@_);
    my $user = pop(@_);
    my @state = @_;
    my $row;

    for($row=0; $row<$ROW_NUM-1 && $state[($row+1)*$COL_NUM+$col] eq $EMPTY; $row++) {}
    $state[$row*$COL_NUM+$col] = $user;
    return ($row, @state)
}


# Check whether the user win the game
#
# Parameters:
#   @state: State of the game
#   $user: Current user (1 or 2)
#   $last_row: row of the last move (start from 0)
#   $last_col: column of the last move (start from 0)
#
# Return:
#   1 for win; Otherwise 0
sub check_win {
    my $last_col = pop(@_);
    my $last_row = pop(@_); 
    my $user = pop(@_);
    my @state = @_;

    my($row, $col);
    my $count = 0;
    
    # check horizontal
    for($col=$last_col; $col<$COL_NUM && $state[$last_row*$COL_NUM+$col] eq $user; $col++) {
        $count++;
    }
    for($col=$last_col-1; $col>=0 && $state[$last_row*$COL_NUM+$col] eq $user; $col--) {
        $count++;
    }
    if($count >= $CONNECT) {
        return 1;
    }

    # check vertical
    $count = 0;
    for($row=$last_row; $row<$ROW_NUM && $state[$row*$COL_NUM+$last_col] eq $user; $row++) {
        $count++;
    }
    for($row=$last_row-1; $row>=0 && $state[$row*$COL_NUM+$last_col] eq $user; $row--) {
        $count++;
    }
    if($count >= $CONNECT) {
        return 1;
    }

    # check diag
    $count = 0;
    for($row=$last_row, $col=$last_col; $row>=0 && $col<$COL_NUM && $state[$row*$COL_NUM+$col] eq $user; $row--, $col++) {
        $count++;
    }
    for($row=$last_row+1, $col=$last_col-1; $row<$ROW_NUM && $col>=0 && $state[$row*$COL_NUM+$col] eq $user; $row++, $col--) {
        $count++;
    }
    if($count >= $CONNECT) {
        return 1;
    }

    # check back diag
    $count = 0;
    for($row=$last_row, $col=$last_col; $row<$ROW_NUM && $col<$COL_NUM && $state[$row*$COL_NUM+$col] eq $user; $row++, $col++) {
        $count++;
    }
    for($row=$last_row-1, $col=$last_col-1; $row>=0 && $col>=0 && $state[$row*$COL_NUM+$col] eq $user; $row--, $col--) {
        $count++;
    }
    if($count >= $CONNECT) {
        return 1;
    }

    return 0;
}

# Check whether the game is tie
#
# Parameters:
#   @state: State of the game
#   $user: Current user (1 or 2)
#   $last_row: row of the last move (start from 0)
#   $last_col: column of the last move (start from 0)
#
# Return:
#   1 for tie; otherwise 0
sub check_tie {
    my $last_col = pop(@_);
    my $last_row = pop(@_);
    my $user = pop(@_);
    my @state = @_;

    my $won = check_win(@state, $user, $last_row, $last_col);
    if($won) {
        return 0;
    }

    foreach my $col (0 .. $COL_NUM-1) {
        if(valid_move(@state, $col)) {
            return 0;
        }
    }

    return 1;
}


# For perl module
1;
