#!/usr/local/bin/perl5 -w

#####################################
# Code examples of the state module #
#####################################

use state;

@state = parse_state("000000010020002021000121100012110102111012");
print_state(@state);
$user = "1";
$col = 4;

($row, @new_state) = move(@state, $user, $col);
print "\n$user move ($row, $col)\n";
print_state(@new_state);

$win = check_win(@new_state, $user, $row, $col);
print "\n$user wins? $win\n";

$tie = check_tie(@new_state, $user, $row, $col);
print "tie? $tie\n";


sub print_state{
    my @state = @_;
    foreach my $row (0 .. $ROW_NUM-1) {
        foreach my $col (0 .. $COL_NUM-1) {
            my $pos = $row * $COL_NUM + $col;
            my $value = $state[$pos];
            if($value eq $EMPTY) {
                print " ";
            }
            else  {
                print $value;
            }
            print " ";
        }
        print "\n";
    }
}
