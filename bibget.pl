#!/usr/bin/perl
#
# Extract used the bibliography elements into a single file
# See http://github.com/DSpinellis/bibget
#
# Copyright 2005-2022 Diomidis Spinellis
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

use strict;
use warnings;

# Files to look for citation records
my @reference_files;
# Citations
my @cites;
# References that were actually used
my %used;

# Collect citations for the specified BibTeX file
sub get_bibtex_citation {
	my($fname) = @_;
	my($IN);
	open ($IN, $fname) || die "Unable to open $fname: $!\n";
	print STDERR "Processing $fname\n";
	while(<$IN>) {
		if (/\\citation\{([^\}]+)\}/) {
			@cites = split(/\,/, $1);
			for my $c (@cites) {
				$used{$c} = 1;
			}
			print STDERR "Found BibTeX citation $1\n";
		} elsif (/\\bibdata\{([^}]+)\}/) {
			@reference_files = split(/,/, $1);
			print STDERR "References in ", join(' ', @reference_files), "\n";
		} elsif (/\\\@input\{([^}]+)\}/) {
			get_bibtex_citation($1);
		}
	}
}

# Collect citations for the specified Biber file
sub get_biber_citation {
	my($fname) = @_;
	my($IN);
	open ($IN, $fname) || die "Unable to open $fname: $!\n";
	print STDERR "Processing $fname\n";
	while(<$IN>) {
		if (/\<bcf:citekey[^>]*\>([^<]+)\<\/bcf:citekey\>/) {
			$used{$1} = 1;
			print STDERR "Found Biber citation $1\n";
		} elsif (/\<bcf:datasource[^>]*datatype=\"bibtex\"[^>]*\>([^<]+)\<\/bcf:datasource\>/) {
			push(@reference_files, $1);
			print STDERR "Add reference file $1\n";
		} elsif (/\<bcf:datasource[^>]*datatype=\"([^"]+)\"/) {
			print STDERR "Skipping unknown data source $1\n";
		}
	}
}

if ($#ARGV == -1) {
	print STDERR "Usage: $0 aux-or-bcf-file ...\n";
	exit 1;
}

for my $name (@ARGV) {
	get_bibtex_citation($name) if ($name =~ m/\.aux/);
	get_biber_citation($name) if ($name =~ m/\.bcf/);
}

print q{% Automatically-generated file; do not edit.
% See http://github.com/DSpinellis/bibget
};

# Heuristic for path separation character
my $bibinputs = $ENV{'BIBINPUTS'} || '.';
my $sepchar = ($bibinputs =~ m/\;/) ? ';' : ':';

while (my $ref_file = shift @reference_files) {
	$ref_file = "$ref_file.bib" unless ($ref_file =~ m/\.bib$/);
	# Open file in BIBINPUTS path
	my $in;
	my $found;
	for my $dir ((split($sepchar, $bibinputs), '.')) {
		if (open($in, "$dir/$ref_file")) {
			print STDERR "Reading references from $dir/$ref_file.bib\n";
			$found = 1;
			last;
		}
	}
	if (!$found) {
		print STDERR "Unable to open $ref_file: $!\n";
		exit 1;
	}

	check: for (;;) {
		print if (defined($_) && /\@string.*\".*\"/i);
		# Output a matched reference
		if (defined($_) && m/^\s*\@\w+\s*[({]\s*([^,]+)/ && $used{$1} && $used{$1} == 1) {
			print $_;
			$used{$1} = 2;
			while (<$in>) {
				next check if (/^\s*\@/);
				print $_;
			}
		}
		last unless (defined($_ = <$in>));
	}
}

# Print elements not found
while (my ($key, $val) = each %used) {
	print STDERR "Not found: $key\n" if ($val == 1);
}
