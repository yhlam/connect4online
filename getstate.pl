#!/usr/local/bin/perl5

# The get state web service
#
# input arguments: 
#   gameid
#   role        1 for game opener, 2 for game joiner
#
# return value: updated current state(if opponent have updated) or empty string (if opponent hvnt updated)


use CGI qw(:standard);
use multiplayer;

print header();

$gameid = param('gameid');
$role = param('role');

$state = retrieveState($gameid, $role);
print $state;
