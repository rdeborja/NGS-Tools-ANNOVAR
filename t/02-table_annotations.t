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
my $test_class = $test_class_factory->class_for('NGS::Tools::ANNOVAR::TableAnnotation');

# instantiate the test class based on the given role
my $annovar;
lives_ok
	{
		$annovar = $test_class->new();
		}
	'Class instantiated';
my $file = 'annovar.input.txt';
my $annovar_run = $annovar->annotate_variants_with_gene_info_and_variant_databases(
	file => $file,
	target => 'target.bed'
	);
my $expected_cmd = join(' ',
	'table_annovar.pl',
	'annovar.input.txt',
	'/usr/local/sw/annovar/annovar.20140212/humandb/',
	'--protocol refGene,ensGene,snp132,1000g2012feb_all,esp6500si_all,cg69,cosmic67',
	'--operation g,g,f,f,f,f,f',
	'--buildver hg19',
	'--remove',
	'--otherinfo'
	);

is($annovar_run->{'cmd'}, $expected_cmd, "ANNOVAR command matches expected");
