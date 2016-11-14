#!/usr/bin/perl
#
# Extract used the bibliography elements into a single file
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
	print STDERR "Reading $fname\n";
	while(<$IN>) {
		if (/\\citation\{([^\}]+)\}/) {
			@cites = split(/\,/, $1);
			for my $c (@cites) {
				$used{$c} = 1;
			}
			print STDERR "Found citation $1\n";
		} elsif (/\\bibdata\{([^}]+)\}/) {
			@refs = split(/,/, $1);
			print STDERR "Read refs from ", join(' ', @refs), "\n";
		} elsif (/\\\@input\{([^}]+)\}/) {
			getcitation($1);
		}
	}
}

getcitation($ARGV[0]);

while ($f = shift @refs) {
	open(IN, "/dds/bib/$f.bib") || die "Unable to open /dds/bib/$f.bib: $!\n";
	check: for (;;) {
		print if (/\@string.*\".*\"/i);
		if (m/^\s*\@\w+\s*[({]\s*([^,]+)/ && $used{$1}) {
			print $_;
			$used{$1} = 2;
			while (<IN>) {
				next check if (/^\s*\@/);
				print $_;
			}
		}
		last unless ($_ = <IN>);
	}
}

#Print elements not found
while (($key, $val) = each %used) {
	print STDERR "Not found: $key\n" if ($val == 1);
}
