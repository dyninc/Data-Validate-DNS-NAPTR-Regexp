package Data::Validate::NAPTR::Regexp;

our $VERSION = '0.001';

use 5.008000;

use strict;
use warnings;

require XSLoader;
XSLoader::load('Data::Validate::NAPTR::Regexp', $VERSION);

require Exporter;

our @ISA = qw(Exporter);

our @EXPORT_OK = qw(is_naptr_regexp naptr_regexp_error);

our @EXPORT = @EXPORT_OK;

my $REG_EXTENDED = constant('REG_EXTENDED');
my $REG_ICASE    = constant('REG_ICASE');

my $last_error;

sub new {
	my ($class) = @_;

	return bless {}, $class;
}

sub _set_error {
	my ($where, $error) = @_;

	if ($where) {
		$where->{error} = $error;
	} else {
		$last_error = $error;
	}
}

sub error {
	my ($self) = @_;

	if ($self) {
		return $self->{error};
	} else {
		return $last_error;
	}
}

sub naptr_regexp_error {
	goto &error;
}

sub is_naptr_regexp {
	my ($self, $string) = @_;

	# Called as a function?
	if (defined $self && !ref $self) {
		$string = $self;

		$self = undef;

		$last_error = undef;
	}

	if (!defined $string) {
		return 1;
	}

	if (!($string =~ s/^(.)//)) {
		return 2;
	}

	if ($string =~ /\0/) {
		_set_error($self, "Contains null bytes");

		return 0;
	}

	my $delim = $1;

	if ($delim =~ /^[0-9\\i\0]$/) {
		_set_error($self, "Delimiter ($delim) cannot be a flag, digit or null");

		return 0;
	}

	$delim = qr/\Q$delim\E/;

	# Convert double-backslashes to \0 for easy parsing
	$string =~ s/\\\\/\0/g;

	unless ($string =~ /^
		(.*) (?<!\\) $delim
		(.*) (?<!\\) $delim
		(.*)$/x
	) {
		_set_error($self, "Bad syntax, missing replace/end delimiter");

		return 0;
	}

	my ($find, $replace, $flags) = ($1, $2, ($3 || ''));

	# Extra delimiters? Broken
	for my $f ($find, $replace, $flags) {
		if ($f =~ /(?<!\\)$delim/) {
			_set_error($self, "Extra delimiters");

			return 0;
		}
	}

	# Convert those nulls back to double backslashes
	$_ =~ s/\0/\\\\/g for ($find, $replace, $flags);

	my $rflags = $REG_EXTENDED;

	# Validate flags
	for my $f (split //, $flags) {
		if ($f eq 'i') {
			$rflags |= $REG_ICASE;
		} else {
			_set_error($self, "Bad flag: $f");

			return 0;
		}
	}

	# Validate regex
	my ($nsub, $err) = _regcomp($find, $rflags);

	if (!defined $nsub) {
		_set_error($self, "Bad regex: $err");

		return 0;
	}

	# Count backrefs in replace and make sure it matches up
	my %brefs = map { $_ => 1 } $replace =~ /(?<!\\)\\([0-9])/g;

	if ($brefs{0}) {
		_set_error($self, "Bad backref '0'");

		return 0;
	}

	my ($highest) = sort {$a <=> $b} keys %brefs;
	$highest ||= 0;

	if ($nsub < $highest) {
		_set_error($self, "More backrefs in replacement than captures in match");

		return 0;
	}

	return 3;
}

1;
__END__

=head1 NAME

Data::Validate::NAPTR::Regexp - Validate the NAPTR Regexp field per RFC 2915

=head1 SYNOPSIS

Functional API (uses globals!!):

  use Data::Validate::NAPTR::Regexp;

  if (is_naptr_regexp('!test(something)!\1test!i')) {
    print "Regexp is okay!";
  } else {
    print "Regexp is invalid: " . naptr_regexp_error();
  }

Object API:

  use Data::Validate::NAPTR::Regexp ();

  my $v = Data::Validate::NAPTR::Regexp->new();

  if ($v->is_naptr_regexp('!test(something)!\1test!i')) {
    print "Regexp is okay!";
  } else {
    print "Regexp is invalid: " . $v->naptr_regexp_error();
  }

  # $v->error() also works

=head1 DESCRIPTION

This module validates the Regexp field in the NAPTR DNS Resource Record as 
defined by RFC 2915.

=head1 EXPORT

By default, L</is_naptr_regexp> and L<naptr_regexp_error> will be exported. If 
you're using the L</OBJECT API>, importing an empty list is recommended.

=head1 FUNCTIONAL API

=head2 Methods

=head3 is_naptr_regexp

  is_naptr_regexp('some-string');

Returns a true value if the provided string is a valid Regexp for an NAPTR 
record. Returns false otherwise. To determine why a Regexp is invalid, see 
L</naptr_regexp_error> below.

=head3 naptr_regexp_error

  naptr_regexp_error();

Returns the last string error from a call to L</is_naptr_regexp> above. This is 
only valid if L</is_naptr_regexp> failed and returns a false value.

=head1 OBJECT API

This is the preferred method as the functional API uses globals.

=head2 Constructor

=head3 new

  Data::Validate::NAPTR::Regexp->new(%args)

Currently no C<%args> are available but this may change in the future.

=head3 is_naptr_regexp

  $v->is_naptr_regexp('some-string');

See L</is_naptr_regexp> above.

=head3 naptr_regexp_error

  $v->naptr_regexp_error();

See L</naptr_regexp_error> above.

=head3 error

  $v->error();

See L</naptr_regexp_error> above.

=head1 SEE ALSO

RFC 2915 - L<https://tools.ietf.org/html/rfc2915>

=head1 AUTHOR

Matthew Horsfall (alh) - <wolfsage@gmail.com>

=head1 CREDITS

The logic for this module was adapted from ISC's BIND - 
L<https://www.isc.org/software/bind>.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 Dyn, Inc.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.9 or,
at your option, any later version of Perl 5 you may have available.

=cut
