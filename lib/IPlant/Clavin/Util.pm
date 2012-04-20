package IPlant::Clavin::Util;

use 5.008;
use strict;
use warnings;

use List::MoreUtils qw(any);

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(blank any_blank);

##########################################################################
# Usage      : $is_blank = blank($str);
#
# Purpose    : Determines if a string is blank.
#
# Returns    : True if the string is not defined, empty or contains only
#              whitespace.
#
# Parameters : $str - the string to check.
#
# Throws     : No exceptions.
sub blank {
    my ($str) = @_;
    return !defined $str || $str =~ m/ \A \s* \z /xms;
}

##########################################################################
# Usage      : $any_blank = any_blank(@strs);
#
# Purpose    : Determines if any string in a list of strings is blank.
#
# Returns    : True if any string in the argument list is not defined,
#              empty or contains only whitespace.
#
# Parameters : $str - the string to check.
#
# Throws     : No exceptions.
sub any_blank {
    return any { blank($_) } @_;
}

exit;
