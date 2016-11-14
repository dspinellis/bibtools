#!/usr/bin/perl
#
# Extract used the bibliography elements into a single file
# See http://github.com/DSpinellis/bibget
#
# Copyright 2005-2016 Diomidis Spinellis
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

sub getcitation {
	my($fname) = @_;
	my($IN);
	open ($IN, $fname) || die;
	print STDERR "Processing $fname\n";
	while(<$IN>) {
		if (/\\citation\{([^\}]+)\}/) {
			@cites = split(/\,/, $1);
			for my $c (@cites) {
				$used{$c} = 1;
			}
			print STDERR "Found citation $1\n";
		} elsif (/\\bibdata\{([^}]+)\}/) {
			@refs = split(/,/, $1);
			print STDERR "References in ", join(' ', @refs), "\n";
		} elsif (/\\\@input\{([^}]+)\}/) {
			getcitation($1);
		}
	}
}

for my $aux (@ARGV) {
	getcitation($aux);
}

# Heuristic for path separation character
my $bibinputs = $ENV{'BIBINPUTS'} || '.';
my $sepchar = ($bibinputs =~ m/\;/) ? ';' : ':';

while ($f = shift @refs) {
	# Open fiel in BIBINPUTS path
	my $in;
	my $found;
	for my $dir (split($sepchar, $bibinputs)) {
		if (open($in, "$dir/$f.bib")) {
			print STDERR "Reading references from $dir/$f.bib\n";
			$found = 1;
			last;
		}
	}
	if (!$found) {
		print STDERR "Unable to open $f: $!\n";
		exit 1;
	}

	check: for (;;) {
		print if (/\@string.*\".*\"/i);
		# Output a matched reference
		if (m/^\s*\@\w+\s*[({]\s*([^,]+)/ && $used{$1}) {
			print $_;
			$used{$1} = 2;
			while (<$in>) {
				next check if (/^\s*\@/);
				print $_;
			}
		}
		last unless ($_ = <$in>);
	}
}

#Print elements not found
while (($key, $val) = each %used) {
	print STDERR "Not found: $key\n" if ($val == 1);
}
