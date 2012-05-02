#!/usr/bin/env perl
use strict;
use warnings;

package nessusIssue;

sub new
{
	
	my $class = shift;
	my $self = {
		_ip => shift,
		_port => shift,
		_CVE => shift,
	};

	bless $self, $class;
	return $self;

}

sub getIp
{
	my ($self) = @_;
	return $self->{_ip};
}

sub getPort
{
	my ($self) = @_;
	return $self->{_port};
}

sub getCVE
{
	my ($self) = @_;
	return $self->{_CVE};
}
1;