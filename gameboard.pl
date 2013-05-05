#!/usr/local/bin/perl5

use CGI qw(:standard);
use state;

$mode = param("mode");
$user = param("user");

$active{$mode} = "class=\"active\"";

print header();

print <<HTML_PART1;
<!DOCTYPE html>
<html>
    <head>
        <title>Connect Four Online</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link href="//cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/2.3.1/css/bootstrap.min.css" rel="stylesheet" media="screen">
        <link href="gameboard.css" rel="stylesheet">
    </head>
    <body>
        <div class="navbar">
            <div class="navbar-inner">
                <a class="brand" href="#">Connect Four Online</a>
                <ul class="nav">
                    <li $active{"single"}><a href="gameboard.pl?user=$user&mode=single">VS Comp</a></li>
                    <li $active{"create"}><a href="gameboard.pl?user=$user&mode=create">Create Game</a></li>
                    <li $active{"join"}><a href="gameboard.pl?user=$user&mode=join">Join Game</a></li>
                    <li><a href="#">Rules</a></li>
                </ul>
            </div>
        </div>
        <div class="container">
            <div class="row">
                <div id="left-panel" class="span3">
                    <div class="row">
                        <div id="red" class="span1"></div>
                        <div class="span2"><h3><span id="user1"></span></h3></div>
                    </div>
                    <div class="row">
                        <div class="span1 offset1" style="text-align:center"><h4>VS</h4></div>
                    </div>
                    <div class="row">
                        <div id="yellow" class="span1"></div>
                        <div class="span2"><h3><span id="user2"></span></h3></div>
                    </div>
                    <div class="row">
                        <div id="console" class="span3"><h1></h1></div>
                    </div>
                </div>
                <div class="span9">
                    <div class="row">
                        <div id="gameboard" class="span7">
HTML_PART1
for $row (0 .. $ROW_NUM-1) {
    print "<div class=\"row\">\n";
    for $col (0 .. $COL_NUM-1) {
        print "<div id=\"cell$row$col\" class=\"span1\"></div>\n";
    }
    print "</div>\n";
}
print <<HTML_PART2;
                        </div>
                    </div>
                    <div class="row">
                        <div id="move-btns" class="span7">
                            <div class="row">
HTML_PART2

for $col (0 .. $COL_NUM-1) {
    print "<div class=\"span1\"><button id=\"btn$col\" class=\"btn\" type=\"button\"><i class=\"icon-arrow-up\"></i></button></div>\n";
}
print <<HTML_PART3;
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div id="modal" class="modal hide fade" data-backdrop="static" data-keyboard="false">
            <div id="modal-header" class="modal-header">
            </div>
            <div id="modal-body" class="modal-body">
            </div>
            <div id="modal-footer" class="modal-footer">
            </div>
        </div>
        <script src="//cdnjs.cloudflare.com/ajax/libs/jquery/2.0.0/jquery.min.js"></script>
        <script src="//cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/2.3.1/js/bootstrap.min.js"></script>
        <script src="gameboard.js.pl?user=$user&mode=$mode"></script>
    </body>
</html>
HTML_PART3

