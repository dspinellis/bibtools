#!/usr/bin/perl

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
