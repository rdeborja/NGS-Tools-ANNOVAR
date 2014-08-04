use Test::More tests => 2;
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
my $test_class = $test_class_factory->class_for('NGS::Tools::ANNOVAR::GeneAnnotation');

# instantiate the test class based on the given role
my $annovar;
lives_ok
	{
		$annovar = $test_class->new();
		}
	'Class instantiated';

my $input = 'input.txt';
my $sample = 'test_sample';
my $annovar_program = 'annotate_variation.pl';
my $annovar_gene_run = $annovar->annotate_variants_with_gene_info(
	annovar => $annovar_program,
	input => $input,
	sample => $sample
	);
my $expected_cmd = join(' ',
	'annotate_variation.pl',
	'input.txt',
	'--buildver hg19',
	'--geneanno',
	'--dbtype refGene',
	'${ANNOVARROOT}/humandb/'
	);
is($annovar_gene_run->{'cmd'}, $expected_cmd, 'ANNOVAR command matches expected');
