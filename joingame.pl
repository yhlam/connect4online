#!/usr/local/bin/perl5

# The join game web service
#
# Input parameter: gameid
# Return: Creator of the game (Empty string if the no corresponding game ID is found)

use CGI qw(:standard);
use multiplayer;

print header();

$gameid = param('gameid');
$user = param('user');
$creator = joinGame($gameid, $user);

print $creator;
