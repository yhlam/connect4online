#!/usr/local/bin/perl5

# The update state web service
#
# input arguments: 
#   gameid
#   role        1 for game opener, 2 for game joiner
#   state
#   user
# return value: 1 for successful, 0 for fail


use CGI qw(:standard);
use multiplayer;
use state;

print header();

$WIN = "win";
$TIE = "tie";
$CONTINUE = "cont";

$gameid = param('gameid');
$role = param('role');
$state_str = param('state');
$user = param('user');
$row = param('row');
$col = param('col');

if(updateState($gameid, $role, $state_str, $user)) {
    @state = parse_state($state_str);
    if(check_win(@state, $role, $row, $col)) {
        print "$WIN";
    }
    elsif(check_tie(@state, $role, $row, $col)) {
        print "$TIE";
    }
    else {
        print "$CONTINUE";
    }
    
}
