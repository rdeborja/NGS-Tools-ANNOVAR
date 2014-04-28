use 5.006;
use strict;
use warnings FATAL => 'all';
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'NGS::Tools::ANNOVAR',
    license             => 'Artistic_2_0',
    dist_author         => q{Richard de Borja <richard.deborja@sickkids.ca>},
    dist_version_from   => 'lib/NGS/Tools/ANNOVAR.pm',
    release_status      => 'stable',
    configure_requires => {
        'Module::Build' => 0,
    },
    build_requires => {
        'Test::More'                => 0,
        'Test::Moose'               => 0,
        'MooseX::ClassCompositor'   => 0,
        'Test::Exception'           => 0,
        'FindBin'                   => 0,
        'File::Temp'                => 0
    },
    requires => {
        'Moose::Role'               => 0,
        'MooseX::Params::Validate'  => 0,
        'namespace::autoclean'      => 0,
        'autodie'                   => 0,
        'File::Basename'            => 0,
        'Moose'                     => 0
    },
    add_to_cleanup     => [ 'NGS-Tools-ANNOVAR-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
