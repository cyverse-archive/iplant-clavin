package IPlant::Clavin;

use 5.008;
use strict;
use warnings;

use Carp;
use Class::Std;
use English qw(-no_match_vars);
use IO::Socket::INET;
use IPlant::Clavin::Util qw(any_blank root_path);
use List::Util qw(first);
use Net::ZooKeeper qw(:node_flags :acls);

use version; our $VERSION = qv(0.1.0);

{
    my %zkh_of      :ATTR;
    my %local_ip_of :ATTR;

    ##########################################################################
    # Usage      : N/A
    #
    # Purpose    : Initializes this class instance.
    #
    # Returns    : Nothing.
    #
    # Parameters : $ident   - the class identifier.
    #              $arg_ref - the reference to the hash or arguments.
    #
    # Throws     : "a value is required for the zk_hosts argument"
    #              "unable to get local IP address"
    #              "unable to establish Zookeeper session: $error_code"
    sub BUILD {
        my ( $self, $ident, $arg_ref ) = @_;

        # Fetch the connection string from the argument list.
        my $zk_hosts = $arg_ref->{zk_hosts};
        croak "missing required argument: zk_hosts"
            if !defined $zk_hosts;
        croak "a value is required for the zk_hosts argument"
            if $zk_hosts =~ m/ \A \s* \z /xms;

        # Get the local IP address used to connect to Zookeeper.
        my $ip = $self->_get_local_ip($zk_hosts);
        croak "unable to get local IP address"
            if !defined $ip;

        # Establish the zookeeper connection.
        my $zkh = Net::ZooKeeper->new($zk_hosts);
        croak "unable to establish Zookeeper session: " . $zkh->get_error()
            if !defined $zkh;

        # Store the attributes.
        $zkh_of{$ident}      = $zkh;
        $local_ip_of{$ident} = $ip;

        return;
    }

    ##########################################################################
    # Usage      : $ip = $clavin->_get_local_ip($zk_hosts);
    #
    # Purpose    : Gets the IP address of the network interface that will be
    #              used to connect to Zookeeper.
    #
    # Returns    : The IP address or undef if an IP address can't be found
    #              (for example, if we can't connect to Zookeeper).
    #
    # Parameters : $zk_hosts - the Zookeeper connection information string.
    #
    # Throws     : No exceptions.
    sub _get_local_ip {
        my ( $self, $zk_hosts ) = @_;
        my $ip;

        # Attempt to connect to each host in the zookeeper cluster.
        NODE:
        for my $node ( split m/,/xms, $zk_hosts ) {
            my ( $host, $port ) = ( split m/:/xms, $node );
            croak "invalid Zookeeper node: $node"
                if any_blank( $host, $port );
            my $sock = IO::Socket::INET->new(
                PeerAddr => $host,
                PeerPort => $port,
                Proto    => 'TCP',
            );
            if ( defined $sock ) {
                $ip = $sock->sockhost();
                last NODE;
            }
        }

        return $ip;
    }

    ##########################################################################
    # Usage      : $deployment = $clavin->_deployment();
    #
    # Purpose    : Gets the name of the appropriate deployment to use for the
    #              local host.
    #
    # Returns    : The deployment name.
    #
    # Parameters : None.
    #
    # Throws     : No exceptions.
    sub _deployment {
        my ($self) = @_;

        # Get the attributes we need.
        my $zkh = $zkh_of{ ident $self };
        my $ip  = $local_ip_of{ ident $self };

        # Find the correct deployment to use for the local host.
        my $path = root_path( "hosts", $ip );
        return first { $_ ne 'admin' } $zkh->get_children($path);
    }

    ##########################################################################
    # Usage      : $node_value = $clavin->_read_node(@components);
    #
    # Purpose    : Gets the value of the node at the path represented by a
    #              list of path components.
    #
    # Returns    : The node value or the empty string if the node doesn't
    #              have a value.
    #
    # Parameters : @components - the list of path components.
    #
    # Throws     : No exceptions.
    sub _read_node {
        my ( $self, @components ) = @_;

        # Get the attributes we need.
        my $zkh = $zkh_of{ ident $self };

        # Fetch the node value.
        my $node_value = $zkh->get( root_path(@components) );

        return defined $node_value ? $node_value : q{};
    }

    ##########################################################################
    # Usage      : $can_run = $clavin->can_run();
    #
    # Purpose    : Determines whether or not a service can run on the local
    #              machine.
    #
    # Returns    : True if a service can run.
    #
    # Parameters : None.
    #
    # Throws     : No exceptions.
    sub can_run {
        my ($self) = @_;
        return defined $self->_deployment();
    }

    ##########################################################################
    # Usage      : $props_ref = $clavin->properties($svc);
    #
    # Purpose    : Retrieves the configuration properties for the given
    #              service.
    #
    # Returns    : A reference to a hash of configuration properties.
    #
    # Parameters : $svc - the name of the service.
    #
    # Throws     : "no deployments are available for the local host"
    sub properties {
        my ( $self, $svc ) = @_;

        # Get the attributes we need.
        my $zkh = $zkh_of{ ident $self };

        # Get the deployment.
        my $deployment = $self->_deployment();
        croak "no deployments are available for the local host"
            if !defined $deployment;

        # Build the deployment path.
        my @components = split m/[.]/xms, $deployment;
        my $dep_path = root_path( @components, $svc );

        # Build the properties hash.
        my @children = $zkh->get_children($dep_path);
        return { map { $_ => $self->_read_node( $dep_path, $_ ) } @children };
    }
}

1;
__END__

=head1 NAME

IPlant::Clavin - Perl module for obtaining service configuration settings from
iPlant's Zookeeper clusters.

=head1 VERSION

This documentation refers to IPlant::Clavin version 0.1.0.

=head1 SYNOPSIS

    use IPlant::Clavin;

    # Create a new Clavin client instance.
    my $clavin = IPlant::Clavin->new(
        { zk_hosts => 'host1:1234,host2:1234' } );

    # Determine whether services are permitted to run on the local host.
    my $can_run = $clavin->can_run();

    # Obtain properties for a service.
    my $props_ref = $clavin->properties('some-service-name');

=head1 DESCRIPTION

IPlant::Clavin provides a convenient way to obtain configuration settings from
iPlant's Zookeeper clusters.  For more information about iPlant's Zookeeper
clusters, please see https://github.com/iPlantCollaborativeOpenSource/Clavin.

=head1 SUBROUTINES/METHODS

=head2 new

Creates a new IPlant::Clavin client instance with the Zookeeper connection
string provided in the named parameter, zk_hosts (which is contained in a hash
reference that is passed to the method).  The Zookeeper connection string
consists of a comma-delimited list of host names and port numbers in which the
host name and port number are separated by a single colon.  For example,
C<by-tor:4321,snow-dog:3421>, represents a two-node Zookeeper cluster with one
intance listening to port 4321 on host by-tor and another instance listening
to port 3421 on host snow-dog.  Here's an example:

    my $conn_str = 'by-tor:4321,snow-dog:3421';
    my $clavin   = IPlant::Clavin->new( { zk_hosts => $conn_str } );

=head3 Arguments

=over 4

=item zk_hosts

the Zookeeper connection string.

=back

=head2 can_run

Determines whether or not services are allowed to run on the current host
according to the ACLs stored in the Zookeeper cluster.  This method returns a
true value if the service can run and a false value if the service can't run.
Here's an example:

    croak "Services are not allowed to run on this machine"
        if !$clavin->can_run();

=head2 properties

Retreives the properties for a named service and returns a reference to a hash
of named properties.  Here's an example:

    my $props_ref         = $clavin->properties('some-svc');
    my $some_config_value = $props_ref->{'some.config.value'};

=head3 Arguments

=over 4

=item $svc

the name of the service.

=back

=head1 DIAGNOSTICS

=head2 missing required argument: zk_hosts

The C<zk_hosts> argument to C<new> was not specified or otherwise left
undefined.  Ensure that C<new> is being called correctly.

=head2 a value is required for the zk_hosts argument

The C<zk_hosts> argument to C<new> was specified, but left blank.  Ensure that
C<new> is being called correctly.

=head2 unable to establish a Zookeeper session

A connection to Zookeeper could not be established.  This is likely to happen
if the entire Zookeeper cluster is down or otherwise unreachable.

=head2 invalid Zookeeper node: $node

One of the components of the Zookeeper connection string was missing or
invalid.  Each component in the string must contain a host name and port
number, separated by a colon.  To fix this, correct the Zookeeper connection
string.

=head2 no deployments are available for the local host

Services are not allowed to run on the local machine but someone called the
C<properties> method anyway.  Ensure that the service is running on the
correct host and that the Clavin ACLs are configured correctly.  It's also a
good idea for services to call C<can_run> before attempting to retrieve
configuration properties.

=head1 CONFIGURATION AND ENVIRONMENT

No special configuration or environment settings are required to use this
module.

=head1 DEPENDENCIES

=head2 Perl

Perl 5.8.0 or above is required.

=head2 Carp

This module comes with the standard Perl distribution.

=head2 Class::Std

Class::Std version 0.011 is required and is available from CPAN.

=head2 English

This module comes with the standard Perl distribution.

=head2 File::Spec::Unix

This module comes with the standard Perl distribution.

=head2 IO::Socket::INET

This module comes with the standard Perl distribution.

=head2 IPlant::Clavin::Util

IPlant::Clavin::Util is included in this module's distribution.

=head2 List::MoreUtils

List::MoreUtils version 0.30 is required and available from CPAN.

=head2 List::Util

List::Util version 1.23 is required and available from CPAN.

=head2 Net::ZooKeeper

Net::ZooKeeper version 0.35 is required and available from CPAN.  I haven't
found a good way to install this module using the standard CPAN client
interface.  Instead, I've found it easiest to download the source from
http://search.cpan.org/CPAN/authors/id/C/CD/CDARROCH/Net-ZooKeeper-0.35.tar.gz
and build it from source.  More details will be provided in the installation
instructions.

=head version

Version 0.88 of this module is required and available from CPAN.

=head2 Zookeeper C Client Library

This is installed with either the C<zookeeper> or C<zookeeper-lib> RPMs on
RedHat-compatible Linux systems.  On other systems, it may be necessary to
install the client library from source.  This library must be installed before
attempting to install Net::ZooKeeper.

=head1 INCOMPATIBILITIES

There are no know incompatibilities at this time.

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
