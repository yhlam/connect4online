#!/usr/local/bin/perl5 -w

use DBI;

$db_name = "102251db";
$mysql_hostname="ihomedb.ust.hk";
$user="102251";
$password="123456";

$dsn = "DBI:mysql:$db_name:$mysql_hostname";
$dbh = DBI->connect($dsn, $user, $password);

if ( !defined $dbh ) {
	die "Cannot connect to MySQL server: $DBI::errstr\n";
}

# functions usage sample:

# create game sample:
# my $gameID=createGame("comp2021");
# print h1($gameID);

# join game sample:
# my $state = joinGame(6);
# print h1("Current Game State: $state");

# update current state sample:
# my $new = "000000000000000000000000000000000000012345";
# $updateResult= updateState(6,1,$new, "stupid");
# print h1("update result: $updateResult");

# retrieve new state sample:
# my $newState = retrieveState(6,1);
# if ($newState == 0){
#	print h1("opponent not yet updated");
# }
# else {	
#	print h1("new state: $newState");
# }

# This function will open a new game in DB, setting the game state to all 0
# and all user update flag to 0
# input: username
# output: gameID (undef if there is an error)
sub createGame{
	my $state = "000000000000000000000000000000000000000000";
        my $username = $_[0];
	my $sth = $dbh->prepare("INSERT INTO comp2021 (current, user1, user2, lastmover) VALUES ('$state',0,0, '$username');"); 
	my $result=$sth->execute();
	if($result!=0){
		$gameID=$sth->{mysql_insertid};
		return $gameID;
	}
}

# This function will join the game by retrieving the current game state
# input arguments: gameID
# return arguments: current state of the game string (undef if the no corresponding game ID is found)
sub joinGame{
	my $gameID = $_[0];
	my $sth = $dbh->prepare("SELECT lastmover FROM comp2021 WHERE gameID = '$gameID';");
	my $result=$sth->execute();
	my @game = $sth->fetchrow_array();

        if(@game) {
	        return $game[0];
        }
}

# This function will send the updated state of the gameboard
# and also set the flag to indicate updated a step
# input arguments: gameID, role, updated state string, username
# role: 1 for game opener, 2 for game joiner
# return value: 1 for successful, 0 for fail
sub updateState{
	
	my $gameID = $_[0];
	my $role = $_[1];
	my $updatedState = $_[2];
        my $username = $_[3];
	my $sth;
	if ($role == 1){
                $sth = $dbh->prepare("UPDATE comp2021 SET current = '$updatedState', user1='1', lastmover= '$username' WHERE gameID = '$gameID';");
	}
	elsif ($role == 2){
                $sth = $dbh->prepare("UPDATE comp2021 SET current = '$updatedState', user2='1', lastmover= '$username' WHERE gameID = '$gameID';");
	}		 
	my $result=$sth->execute();

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
	my $gameID = $_[0];
	my $role = $_[1];
	
	if ($role == 1){
            $sth = $dbh->prepare("SELECT current,lastmover FROM comp2021 WHERE gameID = '$gameID' AND user2 = '1';");
	}
	elsif ($role == 2){
            $sth = $dbh->prepare("SELECT current,lastmover FROM comp2021 WHERE gameID = '$gameID' AND user1 = '1';");
	}		 
	my $result=$sth->execute();

	if (my @row=$sth->fetchrow_array()){
		if ($role == 1){
			$sth = $dbh->prepare("UPDATE comp2021 SET user2 ='0' WHERE gameID = '$gameID';");
		}
		elsif ($role == 2){
			$sth = $dbh->prepare("UPDATE comp2021 SET user1 ='0' WHERE gameID = '$gameID';");
		}		 
		$result=$sth->execute();
		return $row[0], $row[1];
	}
	else {
		return undef;
	}
}

1;
