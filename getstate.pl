#!/usr/local/bin/perl5

# The get state web service
#
# input arguments: 
#   gameid
#   role        1 for game opener, 2 for game joiner
#
# return value: updated current state(if opponent have updated) or empty string (if opponent hvnt updated)


use CGI qw(:standard);
use state;
use multiplayer;

print header();

$TIE = "tie";
$LOSE = "lose";
$CONTINUE = "cont";

$gameid = param("gameid");
$role = param("role");
$state_str = param("state");

@result = retrieveState($gameid, $role);
if(@result > 1) {
    ($newstate_str, $user) = @result;
    @oldstate = split(//, $state_str);
    @newstate = split(//, $newstate_str);

    for $i (0 .. @oldstate-1) {
        if($oldstate[$i] ne $newstate[$i]) {
            $r = int($i / $COL_NUM);
            $c = $i % $COL_NUM;
            $opponent = $role eq "1" ? "2" : "1";
            @state = parse_state($newstate_str);
            if(check_win(@state, $opponent, $r, $c)) {
                print "$user $LOSE $r $c";
            }
            elsif(check_tie(@state, $opponent, $r, $c)) {
                print "$user $TIE $r $c";
            }
            else {
                print "$user $CONTINUE $r $c";
            }
            last;
        }
    }
}
