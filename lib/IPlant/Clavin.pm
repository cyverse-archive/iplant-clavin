package IPlant::Clavin;

use 5.008;
use strict;
use warnings;

use Carp;
use Class::Std;
use English qw(-no_match_vars);
use IO::Socket::INET;
use IPlant::Clavin::Util qw(any_blank);
use Net::Zookeeper qw(:node_flags :acls);

{
    my %zkh_of      :ATTR;
    my %local_ip_of :ATTR;

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
        my $zkh = Net::Zookeeper->new($zk_hosts);
        croak "unable to establish Zookeeper session: $zkh->get_error()"
            if !defined $zkh;

        # Store the zookeeper handle.
        %zkh_of{$ident} = $zkh;

        return;
    }

    sub _get_local_ip {
        my ( $self, $zk_hosts ) = @_;
        my $ip;

        # Attempt to connect to each host in the zookeeper cluster.
        NODE:
        for my $node ( split m/,/xms, $zk_hosts ) {
            my ( $host, $port ) = ( split m/:/xms, $node );
            croak "invalid zookeeper node: $node"
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

    sub _deployment {
        my ($self) = @_;
    }

    sub can_run {
        my ($self) = @_;
        return defined $self->_deployment();
    }
}
