use Test::More tests => 2;
use Test::Files;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use File::Temp qw(tempfile tempdir);
use Data::Dumper;

BEGIN: {
    use_ok('NGS::Tools::ANNOVAR');
    }

my $config_file = "$Bin/../share/default.yaml";
my $input_file = 'input.annovar';
my $annovar = NGS::Tools::ANNOVAR->new();
my $config = $annovar->get_configuration(
    config => $config_file
    );
my $annovar_run = $annovar->annotate_variants_with_gene_info_and_variant_databases(
    file => $input_file,
    protocol => $config->{'protocol'},
    operation => $config->{'operation'},
    buildver => $config->{'buildver'},
    database_dir => $config->{'database_dir'},
    target => 'target.txt',
    vcf => 'filter.vcf'
    );
my $expected_command = join(' ',
    'table_annovar.pl',
    'input.annovar',
    '/hpf/largeprojects/adam/local/reference/homosapiens/ucsc/hg19/annovar/humandb',
    '--protocol',
    'refGene,ensGene,snp132,1000g2012feb_all,esp6500si_all,cg69,cosmic67,clinvar_20150330,exac,bed,vcf',
    '--operation',
    'g,g,f,f,f,f,f,f,f,r,f',
    '--buildver hg19',
    '--remove',
    '--otherinfo',
    '--bedfile target.txt',
    '--vcfdbfile filter.vcf'
    );
is($annovar_run->{'cmd'}, $expected_command, 'Command matches expected');
