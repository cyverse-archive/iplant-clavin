#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'IPlant::Clavin' ) || print "Bail out!\n";
}

diag( "Testing IPlant::Clavin $IPlant::Clavin::VERSION, Perl $], $^X" );
