#!/usr/local/bin/perl5

# The join game web service
#
# Input parameter: gameid
# Return: current state of the game string (Empty string if the no corresponding game ID is found)

use CGI qw(:standard);
use multiplayer;

print header();

$gameid = param('gameid');
$state = joinGame($gameid);

print $state;
