package NGS::Tools::ANNOVAR::TableAnnotation;
use Moose::Role;
use MooseX::Params::Validate;

use strict;
use warnings FATAL => 'all';
use namespace::autoclean;
use autodie;
use File::Basename;

=head1 NAME

NGS::Tools::ANNOVAR::TableAnnotation

=head1 SYNOPSIS

A Perl Moose Role that annotates an ANNOVAR input file using the table_annovar.pl program.

=head1 ATTRIBUTES AND DELEGATES

=head1 SUBROUTINES/METHODS

=head2 $obj->annotate_variants_with_gene_info_and_variant_databases()

Use the table_annovar.pl program to annotate an ANNOVAR input file with gene information and
annotations from various databases.

=head3 Arguments:

=over 2

=item * file:            [Str] input file to process

=item * protocol:        [ArrayRef] contains a list of valid ANNOVAR databases to process

=item * operation:       [ArrayRef] contains a list of characters corresponding to the protocols

=item * database_dir:    [Str] the full path to the ANNOVAR database directory

=item * buildver:        [Str] genome build version (default: hg19)

=item * annovar_program: [Str] full path to the annovar program table_annovar.pl (default: table_annovar.pl)

=item * target:          [Str] name of BED file target to use (default: '')

=item * vcf:             [Str] name of VCF file to use for annotation purposes (default: '')

=back
`4
=head3 Return Value

A hash reference containing the following keys:

=over 2

=item * cmd: command to execute

=item * output: name of output file

=back

=cut

sub annotate_variants_with_gene_info_and_variant_databases {
    my $self = shift;
    my %args = validated_hash(
        \@_,
        file => {
            isa         => 'Str',
            required    => 1
            },
        protocol => {
            isa         => 'ArrayRef',
            required    => 0,
            default     => ['refGene', 'ensGene', 'snp132', '1000g2012feb_all', 'esp6500si_all', 'cg69', 'cosmic67']
            },
        operation => {
            isa         => 'ArrayRef',
            required    => 0,
            default     => ['g', 'g', 'f', 'f', 'f', 'f', 'f']
            },
        database_dir => {
            isa         => 'Str',
            required    => 0,
            default     => '/hpf/largeprojects/adam/ref_data/homosapiens/ucsc/hg19/annovar/20140212/humandb/'
            },
        buildver => {
            isa         => 'Str',
            required    => 0,
            default     => 'hg19'
            },
        annovar_program => {
            isa         => 'Str',
            required    => 0,
            default     => 'table_annovar.pl'
            },
        target => {
            isa         => 'Str',
            required    => 0,
            default     => ''
            },
        vcf => {
            isa         => 'Str',
            required    => 0,
            default     => ''
            }
        );

    # if the target argument is passed with a non-empty string, add the -bed parameter
    # to the table_annovar.pl program and include 
    if ($args{'target'} ne '') {
        push(@{ $args{'protocol'} }, 'bed');
        push(@{ $args{'operation'} }, 'r')
        }
    # a VCF file can be used as a filter file, this will annotate the 
    if ($args{'vcf'} ne '') {
        push(@{ $args{'protocol'} }, 'vcf');
        push(@{ $args{'operation'} }, 'f');
        }
    my $protocol = join(',', @{ $args{'protocol'} });
    my $operation = join(',', @{ $args{'operation'} });
    my $program = $args{'annovar_program'};
    my $cmd = join(' ',
        $program,
        $args{'file'},
        $args{'database_dir'},
        '--protocol', $protocol,
        '--operation', $operation,
        '--buildver', $args{'buildver'},
        '--remove',
        '--otherinfo'
        );

    # we can add a single custom BED file and use this as an annotation
    if ($args{'target'} ne '') {
        $cmd = join(' ',
            $cmd,
            '--bedfile', $args{'target'}
            );
        }
    # next we can add a single VCF file and use this for annotation/filter purposes
    if ($args{'vcf'} ne '') {
        $cmd = join(' ',
            $cmd,
            '--vcfdbfile', $args{'vcf'}
            );
        }

    # check if the input file is a VCF, if it is a VCF file, add the -vcfinput argument
    # to the command
    if ($args{'file'} =~ m/\.vcf$/) {
        $cmd = join(' ',
            $cmd,
            '-vcfinput'
            );
        }

    my %return_values = (
        cmd => $cmd,
        output => join('.', $args{'file'}, 'hg19_multianno.txt')
        );

    return(\%return_values);
    }

=head1 AUTHOR

Richard de Borja, C<< <richard.deborja at sickkids.ca> >>

=head1 ACKNOWLEDGEMENT

Dr. Adam Shlien, PI -- The Hospital for Sick Children

Andrej Rosic -- The Hospital for Sick Children, Waterloo University

=head1 BUGS

Please report any bugs or feature requests to C<bug-test-test at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=test-test>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc NGS::Tools::ANNOVAR::TableAnnotation

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=test-test>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/test-test>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/test-test>

=item * Search CPAN

L<http://search.cpan.org/dist/test-test/>

=back

=head1 ACKNOWLEDGEMENTS

=head1 LICENSE AND COPYRIGHT

Copyright 2013 Richard de Borja.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

no Moose::Role;

1; # End of NGS::Tools::ANNOVAR::TableAnnotation
