package IPlant::Clavin::Util;

use 5.008;
use strict;
use warnings;

use File::Spec::Unix;
use List::MoreUtils qw(any);

use version; our $VERSION = qv(0.1.0);

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(blank any_blank root_path);

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

##########################################################################
# Usage      : $path = root_path(@components);
#
# Purpose    : Builds a root Zookeeper path from the given path
#              components.  If the first component in the argument list
#              does not begin with a slash then a leading slash will be
#              added.
#
# Returns    : The path.
#
# Parameters : @components - the path components.
#
# Throws     : No exceptions.
sub root_path {
    my @components = @_;
    if ( scalar @components == 0 || $components[0] !~ m{ \A / }xms ) {
        unshift @components, File::Spec::Unix->rootdir();
    }
    return File::Spec::Unix->catfile(@components);
}

1;

__END__

=head1 NAME

IPlant::Clavin::Util - utility methods for IPlant::Clavin.

=head1 VERSION

This documentation refers to IPlant::Clavin::Util version 0.1.0.

=head1 SYNOPSIS

    use IPlant::Clavin::Util qw(blank any_blank root_path);
    my $is_blank  = blank($str);
    my $any_blank = any_blank(@strs);
    my $root_path = root_path(@components);

=head1 DESCRIPTION

This module contains utility functions that are used by IPlant::Clavin, but
don't really fit into an object-oriented model.

=head1 SUBROUTINES/METHODS

=head2 blank

Returns a true value if the argument is undefined, an empty string or a string
that contains only whitespace.

=head3 Arguments

=over 4

=item $str

the string to check.

=back

=head2 any_blank

Returns a true value if any of the strings in the argument list is undefined,
empty or contains only whitespace.

=head3 Arguments:

=over 4

=item @strs

the list of strings to check.

=back

=head2 root_path

Combines the arguments into an absolute path that can be used to access a node
in Zookeeper.  If the first component doesn't begin with a slash then a
leading slash will be added automatically.

=head3 Arguments

=over 4

=item @components

the list of path components.

=back

=head1 DEPENDENCIES

=head2 File::Spec::Unix

This module comes with the standard Perl distribution.

=head2 List::MoreUtils

List::MoreUtils version 0.30 is required and available from CPAN.

=head1 INCOMPATIBILITIES

There are no known incompatibilities at this time.

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.  Please report problems to the core
software development team.  Patches are welcome.

=head1 AUTHOR

Dennis Roberts (dennis@iplantcollaborative.org)

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2012, The Arizona Board of Regents on behalf of The University
of Arizona

All rights reserved.

Developed by: iPlant Collaborative at BIO5 at The University of Arizona
http://www.iplantcollaborative.org

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

 * Neither the name of the iPlant Collaborative, BIO5, The University of
   Arizona nor the names of its contributors may be used to endorse or promote
   products derived from this software without specific prior written
   permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut
