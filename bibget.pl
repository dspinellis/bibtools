# Extract used the bibliography elements into a single file

sub getcitation {
	my($fname) = @_;
	my($IN);
	open ($IN, $fname) || die;
	print STDERR "Reading $fname\n";
	while(<$IN>) {
		$used{$1} = 1 if (/\\citation\{([^\}]+)\}/);
		@refs = split(/,/, $1) if (/\\bibdata\{([^}]+)\}/);
		getcitation($1) if (/\\\@input\{([^}]+)\}/);
	}
}

getcitation('coderead.aux');

@refs = split(/,/, "macro,sec,mp,mybooks,myart,struct,perl,classics,coderead,unix,various,haskell,rfc");

while ($f = shift @refs) {
	open(IN, "/dds/bib/$f.bib") || die "Unable to open /dds/bib/$f.bib: $!\n";
	check: for (;;) {
		if (m/^\s*\@\w+\s*[({]\s*(\w+)/ && $used{$1}) {
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
