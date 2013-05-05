#!/usr/local/bin/perl5

# This is the CGI AI web service.
#
# 3 parameters should be passed to this web service
#     state: The state string of the current game board
#     last_row: The row of the last move of the user
#     last_col: The column of the last move of the user
#
# Return of the web service would be in the following format
#     [RESULT] [ROW] [COL]
#
#     RESULT := win | tie | lose | cont
#     ROW := 0-6 (Only persent if AI has to move)
#     COL := 0-5 (Only persent if AI has to move)


use CGI qw(:standard);
use state;

print header();

$CALC_STEP = 4;

$USER = "1";
$AI = "2";

$WIN = "win";
$TIE = "tie";
$LOSE = "lose";
$CONTINUE = "cont";

$state_str = param("state");
$last_row = param("last_row");
$last_col = param("last_col");

@state = parse_state($state_str);

if(check_win(@state, $USER, $last_row, $last_col)) {
    print "$WIN";
}
elsif(check_tie(@state, $USER, $last_row, $last_col)) {
    print "$TIE";
}
else {
    ($row, $col, @new_state) = get_ai_move(@state, $USER, $last_row, $last_col);
    $new_state_str = format_state(@new_state);

    if(check_win(@new_state, $AI, $row, $col)) {
        print "$LOSE $row $col";
    }
    elsif(check_tie(@new_state, $AI, $row, $col)) {
        print "$TIE $row $col";
    }
    else {
        print "$CONTINUE $row $col";
    }
}


# Get AI move for the given game board state
#
# Paramter:
#   @state: the state of the game board
#
# Return:
#   $row: the row of the AI's move
#   $col: the column of the AI's move
#   @new_state: the new state of the game board after the AI's move
sub get_ai_move {
    my $last_col = pop(@_);
    my $last_row = pop(@_);
    my $user = pop(@_);
    my @state = @_;
    my($score, $col) = max_recurse(@state, $user, $last_row, $last_col, $CALC_STEP, "-inf", "+inf");
    my($row, @new_state) = move(@state, $AI, $col);

    return ($row, $col, @new_state);
}


# # # # # # # # # # # # # # # # # # # # # # # 
# SHOULD NOT BE CALLED OUTSIDE get_ai_move  #
# # # # # # # # # # # # # # # # # # # # # # #


sub max_recurse {
    my $beta = pop(@_);
    my $alpha = pop(@_);
    my $depth = pop(@_);
    my $last_col = pop(@_);
    my $last_row = pop(@_);
    my $user = pop(@_);
    my @state = @_;

    if($depth == 0) {
        return heuristic(@state, $user, $last_row, $last_col);
    }

    my $score = "-inf";
    my $best_move;
    my $next_user;
    if($user eq $AI) {
        $next_user = $USER;
    }
    else {
        $next_user = $AI;
    }

    foreach my $col (0 .. $COL_NUM-1) {
        if(valid_move(@state, $col)) {
            my($row, @new_state) = move(@state, $next_user, $col);

            if(check_win(@new_state, $next_user, $row, $col)) {
                $score = "+inf";
                $best_move = $col;
            }

            my($min, $min_move) = min_recurse(@new_state, $next_user, $row, $col, $depth-1, $alpha, $beta);
            if($min >= $score) {
                $score = $min;
                $best_move = $col;
            }

            if($score > $beta) {
                return "+inf";
            }

            if($score > $alpha) {
                $alpha = $score;
            }
        }
    }

    return ($score, $best_move);
}


sub min_recurse {
    my $beta = pop(@_);
    my $alpha = pop(@_);
    my $depth = pop(@_);
    my $last_col = pop(@_);
    my $last_row = pop(@_);
    my $user = pop(@_);
    my @state = @_;

    if($depth == 0) {
        return heuristic(@state, $user, $last_row, $last_col);
    }

    my $score = "+inf";
    my $best_move;
    my $next_user;
    if($user eq $AI) {
        $next_user = $USER;
    }
    else {
        $next_user = $AI;
    }


    foreach my $col (0 .. $COL_NUM-1) {
        if(valid_move(@state, $col)) {
            my($row, @new_state) = move(@state, $next_user, $col);

            if(check_win(@new_state, $next_user, $row, $col)) {
                $score = "-inf";
                $best_move = $col;
            }

            my($max, $max_move) = max_recurse(@new_state, $next_user, $row, $col, $depth-1, $alpha, $beta);
            if($max <= $score) {
                $score = $max;
                $best_move = $col;
            }

            if($score < $alpha) {
                return "-inf";
            }

            if($score < $beta) {
                $beta = $score;
            }
        }
    }

    return ($score, $best_move);
}


sub heuristic {
    my $last_col = pop(@_);
    my $last_row = pop(@_);
    my $user = pop(@_);
    my @state = @_;
    if(check_win(@state, $user, $last_row, $last_col)) {
        if($user eq $AI) {
            return "+inf";
        }
        else {
            return "-inf";
        }
    }

    my $score = 0;
    foreach my $row (0 .. $ROW_NUM-1) {
        foreach my $col (0 .. $COL_NUM-1) {
            my $value = $state[$row * $COL_NUM + $col];
            if($value ne $USER) {
                my($i, $j);

                # horizontal
                my $count = 1;
                my $value_added = $value eq $AI ? 2 : 1;
                for($j=$col+1; $j<$COL_NUM && $j<$col+$CONNECT; $j++) {
                    $cell = $state[$row * $COL_NUM + $j];
                    if($cell eq $USER) {
                        last;
                    }
                    elsif($cell eq $AI) {
                        $value_added += 2;
                    }
                    else {
                        $value_added += 1;
                    }
                    $count++;
                }
                if($count >= $CONNECT) {
                    $score += $value_added;
                }

                # vertical
                $count = 1;
                $value_added = $value eq $AI ? 2 : 1;
                for($i=$row+1; $i<$ROW_NUM && $i<$row+$CONNECT; $i++) {
                    $cell = $state[$i * $COL_NUM + $col];
                    if($cell eq $USER) {
                        last;
                    }
                    elsif($cell eq $AI) {
                        $value_added += 2;
                    }
                    else {
                        $value_added += 1;
                    }
                    $count++;
                }
                if($count >= $CONNECT) {
                    $score += $value_added;
                }

                # diag
                $count = 1;
                $value_added = $value eq $AI ? 2 : 1;
                for($i=$row-1, $j=$col+1; $i>=0 && $i>$row-$CONNECT && $j<$COL_NUM && $j<$col+$CONNECT; $i--, $j++) {
                    $cell = $state[$i*$COL_NUM+$j];
                    if($cell eq $USER) {
                        last;
                    }
                    elsif($cell eq $AI) {
                        $value_added += 2;
                    }
                    else {
                        $value_added += 1;
                    }
                    $count++;
                }
                if($count >= $CONNECT) {
                    $score += $value_added;
                }

                # back diag
                $count = 1;
                $value_added = $value eq $AI ? 2 : 1;
                for($i=$row+1, $j=$col+1; $i<$ROW_NUM && $i<$row+$CONNECT && $j<$COL_NUM && $j<$col+$CONNECT; $i++, $j++) {
                    $cell = $state[$i*$COL_NUM+$j];
                    if($cell eq $USER) {
                        last;
                    }
                    elsif($cell eq $AI) {
                        $value_added += 2;
                    }
                    else {
                        $value_added += 1;
                    }
                    $count++;
                }
                if($count >= $CONNECT) {
                    $score += $value_added;
                }
            }
        }
    }
    return $score
}
