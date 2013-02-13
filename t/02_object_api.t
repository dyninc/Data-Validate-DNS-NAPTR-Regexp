#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Data::Validate::NAPTR::Regexp qw(naptr_regexp_error);

# Good tests
my %good = (
	qw(^test^test^)              => 3,
	qw(^test\\\\\\\\^bo\\\\b^)   => 3,
	qw(^test^bob^i)              => 3,
	qw(^test(cat)^bob\1^)        => 3,
	qw(!bird(cat)(dog)!bob\2\1!) => 3,
	qw(!bird(cat)(dog)!bob\1!)   => 3,
	qw(^test\^this^cat\^dog^i)   => 3,
	qw(:test:nonsense\b\a:)      => 3,
	qw(^((){10}){10}/^cat^)      => 3,
	'^' . ('x' x 250) . '^34^'  => 3,
);

for my $c (keys %good) {
	my $v = Data::Validate::NAPTR::Regexp->new();

	is($v->is_naptr_regexp($c), $good{$c}, (defined $c ? "'$c'" : "'<undef>'") . " is a valid regexp")
		or diag("Got error: " . $v->error());
}

my $v = Data::Validate::NAPTR::Regexp->new();

is($v->is_naptr_regexp(undef), 1, "undef string is a valid regexp")
	or diag("Got error: " . naptr_regexp_error());

is($v->is_naptr_regexp(''), 2, "Empty string is a valid regexp")
	or diag("Got error: " . naptr_regexp_error());

# Bad tests
my %bad = (
	"\0test\0test\0"      => qr/Contains null bytes$/,
	qw(^test^)            => qr/Bad syntax, missing replace\/end delimiter$/,
	qw(^test^bob)         => qr/Bad syntax, missing replace\/end delimiter$/,
	qw(^test^bob^i^i)     => qr/Extra delimiters$/,
	qw(0test0bob0)        => qr/Delimiter \(0\) cannot be a flag, digit or null$/,
	qw(1test1bob1)        => qr/Delimiter \(1\) cannot be a flag, digit or null$/,
	qw(9test9bob9)        => qr/Delimiter \(9\) cannot be a flag, digit or null$/,
        qw(itestibobi)        => qr/Delimiter \(i\) cannot be a flag, digit or null$/,
	qw(\test\bob\\)       => qr/Delimiter \(\\\) cannot be a flag, digit or null$/,
	qw(^test(cat)^bob\2^) => qr/More backrefs in replacement than captures in match$/,
	qw(^test^bob^if)      => qr/Bad flag: f$/,
	qw(^tes\(cat^bob^)    => qr/Bad regex: .+$/,
	qw(^test^\0^)         => qr/Bad backref '0'$/,
	'^' . ('x' x 250) . '^234^'  => qr/Must be less than 256 bytes$/,
);

for my $c (keys %bad) {
	my $v = Data::Validate::NAPTR::Regexp->new();

	ok(!$v->is_naptr_regexp($c), "$c is not a valid regexp");
	like($v->error(), $bad{$c}, "Got expected error $bad{$c}");
	like($v->naptr_regexp_error(), $bad{$c}, "Got expected error $bad{$c}");
	is(naptr_regexp_error(), undef, "Global error unset");
}

done_testing;
