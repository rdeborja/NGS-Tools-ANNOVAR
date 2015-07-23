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
	protocol => ['refGene', 'ensGene', 'snp132', '1000g2012feb_all', 'esp6500si_all', 'cg69', 'cosmic67', 'clinvar_20150330', 'exac'],
	operation => ['g', 'g', 'f' ,'f', 'f', 'f', 'f', 'f', 'f'],
	buildver => 'hg19',
	database_dir => "$Bin/example/target",
 	target => 'target.txt',
 	vcf => 'filter.vcf'
	);
my $expected_cmd = join(' ',
	'table_annovar.pl',
	'annovar.input.txt',
	"$Bin/example/target",
	'--protocol refGene,ensGene,snp132,1000g2012feb_all,esp6500si_all,cg69,cosmic67,clinvar_20150330,exac,bed,vcf',
	'--operation g,g,f,f,f,f,f,f,f,r,f',
	'--buildver hg19',
	'--remove',
	'--otherinfo',
	'--bedfile target.txt',
	'--vcfdbfile filter.vcf'
	);

is($annovar_run->{'cmd'}, $expected_cmd, "ANNOVAR command matches expected");
