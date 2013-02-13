use 5.008000;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Data::Validate::NAPTR::Regexp',
    VERSION_FROM      => 'lib/Data/Validate/NAPTR/Regexp.pm', # finds $VERSION
    PREREQ_PM         => {
      'ExtUtils::Constant' => 0.16,
    }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Data/Validate/NAPTR/Regexp.pm', # retrieve abstract from module
       AUTHOR         => 'Matthew Horsfall <mhorsfall@mht.dyndns.com>') : ()),
    LIBS              => [''], # e.g., '-lm'
    DEFINE            => '', # e.g., '-DHAVE_SOMETHING'
    INC               => '-I.', # e.g., '-I. -I/usr/include/other'
	# Un-comment this if you add C files to link with later:
    # OBJECT            => '$(O_FILES)', # link all the C files too
);

my @constants = qw(
	REG_EXTENDED
	REG_ICASE
	REG_NEWLINE
);

eval 'use ExtUtils::Constant';
if( not $@ ) {
    ExtUtils::Constant::WriteConstants(
   NAME    => 'Data::Validate::NAPTR::Regexp',
   NAMES   => \@constants,
   DEFAULT_TYPE => 'IV',
   C_FILE  => 'const-c.inc',
   XS_FILE => 'const-xs.inc',
    );
}


