#!/usr/local/bin/perl5 -w

use CGI qw (:standard -debug);
use CGI qw (:standard);
use DBI;

$db_name = "102251db";
$mysql_hostname="ihomedb.ust.hk";
$user="102251";
$password="123456";

$dsn = "DBI:mysql:$db_name:$mysql_hostname";
$dbh = DBI->connect($dsn, $user, $password);

print header();
print start_html("DB Connection Testing");

if ( !defined $dbh ) {
	die "Cannot connect to MySQL server: $DBI::errstr\n";
}
else{
print h1("DB connection succeeded");
}

print h1("insert record trial");

# functions usage sample:

# create game sample:
# my $gameID=createGame();
# print h1($gameID);

# join game sample:
# my $state = joinGame(6);
# print h1("Current Game State: $state");

# update current state sample:
# my $new = "000000000000000000000000000000000000012345";
# $updateResult= updateState(6,1,$new);
# print h1("update result: $updateResult");

# retrieve new state sample:
# my $newState = retrieveState(6,1);
# if ($newState == 0){
#	print h1("opponent not yet updated");
# }
# else {	
#	print h1("new state: $newState");
# }

print end_html();

# This function will open a new game in DB, setting the game state to all 0
# and all user update flag to 0
# input: nothing
# output: gameID
sub createGame{
	$state = "000000000000000000000000000000000000000000";
	my $sth = $dbh->prepare("INSERT INTO comp2021 (current, user1, user2) VALUES ('$state',0,0);"); 
	$result=$sth->execute();
	if($result!=0){
		print h1("Insert Record Function is OK");
		print h1($result);
		$gameID=$sth->{mysql_insertid};
		return $gameID;
	}
	else{
		print h1("Insert Record Function Failed");
	}
}

# This function will join the game by retrieving the current game state
# input arguments: gameID
# return arguments: current state of the game string
sub joinGame{
	$gameID = $_[0];
	print h1("gameID: $gameID");
	my $sth = $dbh->prepare("SELECT current FROM comp2021 WHERE gameID = '$gameID';");
	$result=$sth->execute();
	@game = $sth->fetchrow_array();
	return $game[0];
}

# This function will send the updated state of the gameboard
# and also set the flag to indicate updated a step
# input arguments: gameID, role, updated state string
# role: 1 for game opener, 2 for game joiner
# return value: 1 for successful, 0 for fail
sub updateState{
	
	$gameID = $_[0];
	$role = $_[1];
	$updatedState = $_[2];
	my $sth;
	if ($role == 1){
		print h1("case 1");
		$sth = $dbh->prepare("UPDATE comp2021 SET current = '$updatedState', user1='1' WHERE gameID = '$gameID';");
	}
	elsif ($role == 2){
		print h1("case 2");
		$sth = $dbh->prepare("UPDATE comp2021 SET current = '$updatedState', user2='1' WHERE gameID = '$gameID';");
	}		 
	$result=$sth->execute();

	if ($result == 1){
		return 1;
	}
	else {
		return 0;
	}
		
}

# This function will chk if the opponent have updated by checking the update flag in DB
# if the update flag of opponent is set, the will return updated state, return undef otherwise
# this function will also clear the flag of the opponent update flag
# input arguments: gameID, role
# role: 1 for game opener, 2 for game joiner
# return value: updated current state(if opponent have updated) or undef(if opponent hvnt updated)
sub retrieveState{
	$gameID = $_[0];
	$role = $_[1];
	
	$gameID = $_[0];
	$role = $_[1];

	if ($role == 1){
		$sth = $dbh->prepare("SELECT current FROM comp2021 WHERE gameID = '$gameID' AND user2 = '1';");
	}
	elsif ($role == 2){
		$sth = $dbh->prepare("SELECT current FROM comp2021 WHERE gameID = '$gameID' AND user1 = '1';");
	}		 
	$result=$sth->execute();

	if (@row=$sth->fetchrow_array()){
		if ($role == 1){
			$sth = $dbh->prepare("UPDATE comp2021 SET user2 ='0' WHERE gameID = '$gameID';");
		}
		elsif ($role == 2){
			$sth = $dbh->prepare("UPDATE comp2021 SET user1 ='0' WHERE gameID = '$gameID';");
		}		 
		$result=$sth->execute();
		return $row[0];
	}
	else {
		return undef;
	}
}
