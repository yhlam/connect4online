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

print header();

$gameid = param('gameid');
$role = param('role');
$state = param('state');
$user = param('user');

$result = updateState($gameid, $role, $state, $user);
print $result;
