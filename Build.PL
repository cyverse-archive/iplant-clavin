use 5.008;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name        => 'IPlant::Clavin',
    license            => 'perl',
    dist_author        => q{Dennis Roberts <dennis@iplantcollaborative.org>},
    dist_version_from  => 'lib/IPlant/Clavin.pm',
    build_requires     => { 'Test::More' => 0, },
    configure_requires => { 'Module::Build' => 0.38 },
    requires           => {
        'Carp'             => 0,
        'Class::Std'       => 0.011,
        'English'          => 0,
        'File::Spec::Unix' => 0,
        'IO::Socket::INET' => 0,
        'List::MoreUtils'  => 0.30,
        'List::Util'       => 1.23,
        'Net::ZooKeeper'   => 0.35,
        'perl'             => 5.008,
        'version'          => 0.88,
    },
    add_to_cleanup     => ['IPlant-Clavin-*'],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
