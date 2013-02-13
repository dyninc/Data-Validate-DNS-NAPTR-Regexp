package inc::MyDistMakeMaker;
use Moose;

extends 'Dist::Zilla::Plugin::MakeMaker::Awesome';

override _build_MakeFile_PL_template => sub {
	my ($self) = @_;
	my $template = super();

	$template .= <<'TEMPLATE';
my @constants = qw(
	REG_EXTENDED
	REG_ICASE
	REG_NEWLINE
);

eval 'use ExtUtils::Constant';
if( not $@ ) {
    ExtUtils::Constant::WriteConstants(
   NAME    => 'Data::Validate::DNS::NAPTR::Regexp',
   NAMES   => \@constants,
   DEFAULT_TYPE => 'IV',
   C_FILE  => 'const-c.inc',
   XS_FILE => 'const-xs.inc',
    );
}

TEMPLATE

	return $template;
};

__PACKAGE__->meta->make_immutable;
