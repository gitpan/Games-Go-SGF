use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Games::Go::SGF',
    AUTHOR              => 'Daniel Gilder <degatcpan@ntlworld.com>',
    VERSION_FROM        => 'lib/Games/Go/SGF.pm',
    ABSTRACT_FROM       => 'lib/Games/Go/SGF.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Games-Go-SGF-*' },
);
