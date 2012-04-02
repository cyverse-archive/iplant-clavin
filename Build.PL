use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'IPlant::Clavin',
    license             => 'perl',
    dist_author         => q{Dennis Roberts <dennis@iplantcollaborative.org>},
    dist_version_from   => 'lib/IPlant/Clavin.pm',
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        'perl' => 5.006,
    },
    add_to_cleanup      => [ 'IPlant-Clavin-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
