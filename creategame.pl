#!/usr/local/bin/perl5

# The create game web service
#
# No input is required.
# The game ID will be returned. (Empty string if failed to create the game)

use CGI qw(:standard);
use multiplayer;

print header();

$gameid = createGame();

print $gameid;
