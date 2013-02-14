#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Data::Validate::DNS::NAPTR::Regexp;

# Good tests
my %good = (
	qw(^t\\097est^test^)         => 3,
	qw(^t\\097^test^)            => 3,
	qw(^t\\bah^test^)            => 3,
	qw(^test^\\097^)             => 3,
	qw(^test^\\098a^)            => 3,
	qw(^test\\\\\\\\^bo\\\\b^)   => 3,
	qw(^test^bob^i)              => 3,
	qw(^test(cat)^bob\\\\1^)        => 3,
	qw(!bird(cat)(dog)!bob\\\\2\\\\1!) => 3,
	qw(!bird(cat)(dog)!bob\\\\1!)   => 3,
	qw(^test\^this^cat\^dog^i)   => 3,
	qw(:test:nonsense\b\a:)      => 3,
	qw(^((){10}){10}/^cat^)      => 3,
	'^' . ('x' x 250) . '^34^'  => 3,
	qw(^test(cat)^\\\\\\\\9^)   => 3, # This is not a backref
);

for my $c (keys %good) {
	is(is_naptr_regexp($c), $good{$c}, (defined $c ? "'$c'" : "'<undef>'") . " is a valid regexp")
		or diag("Got error: " . naptr_regexp_error());
}

is(is_naptr_regexp(undef), 1, "undef string is a valid regexp")
	or diag("Got error: " . naptr_regexp_error());

is(is_naptr_regexp(''), 2, "Empty string is a valid regexp")
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
	qw(^test(cat)^bob\\\\2^) => qr/More backrefs in replacement than captures in match$/,
	qw(^test^bob^if)      => qr/Bad flag: f$/,
	qw(^tes\(cat^bob^)    => qr/Bad regex: .+$/,
	qw(^test^\\\\0^)         => qr/Bad backref '0'$/,
	'^' . ('x' x 250) . '^234^'  => qr/Must be less than 256 bytes$/,
	qw(^test\\25a^bah^)   => qr/Bad escape sequence '\\25'$/,
	qw(^test^\\25b^)      => qr/Bad escape sequence '\\25'$/,
	qw(^test\\256b^bah^)   => qr/Escape sequence out of range '\\256'/,
	qw(^test^bah\\256a^)   => qr/Escape sequence out of range '\\256'/,
);

for my $c (keys %bad) {
	ok(!is_naptr_regexp($c), "$c is not a valid regexp");
	like(naptr_regexp_error(), $bad{$c}, "Got expected error $bad{$c}");
}

done_testing;
