use Test::More tests => 4;
use Test::Moose;
use Test::Exception;
use MooseX::ClassCompositor;
use Test::Files;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use File::Temp qw(tempfile tempdir);
use Data::Dumper;

# setup the class creation process
my $test_class_factory = MooseX::ClassCompositor->new(
    { class_basename => 'Test' }
    );

# create a temporary class based on the given Moose::Role package
my $test_class = $test_class_factory->class_for('NGS::Tools::ANNOVAR::Config');

# instantiate the test class based on the given role
my $annovar;
my $config_file = "$Bin/../share/default.yaml";
lives_ok
    {
        $annovar = $test_class->new();
        }
    'Class instantiated';

my $annovar_config = $annovar->get_configuration(config => $config_file);
my $annovar_config_op_string = join('',
    @{$annovar_config->{'operation'}}
    );
my $annovar_config_protocol_string = join('',
    @{$annovar_config->{'protocol'}}
    );
my $expected_operations = join('',
    'g',
    'g',
    'f',
    'f',
    'f',
    'f',
    'f',
    'f',
    'f'
    );
my $expected_protocols = join('',
    'refGene',
    'ensGene',
    'snp132',
    '1000g2012feb_all',
    'esp6500si_all',
    'cg69',
    'cosmic67',
    'clinvar_20150330',
    'exac'
    );
is($annovar_config->{'buildver'}, 'hg19', 'Build version is hg19');
is($annovar_config_op_string, $expected_operations, 'Operation matches expected');
is($annovar_config_protocol_string, $expected_protocols, 'Protocol matches expected');
