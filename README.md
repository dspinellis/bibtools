# Bibtools: Tools for working with BibTeX bibliography files
This repository hosts simple tools I've developed for working
with BibTeX bibliography files.
They help sharing references with co-authors and navigating to
bibliography entries from the editor.
See also the
[advice for working with LaTeX](https://github.com/dspinellis/latex-advice)
repository.

## Installation
Run `make install` to install the files in the `/usr/local/bin` directory.
If you lack administrator privileges or want to install the files
in a different directory, specify it as the `PREFIX` variable
when running _make_, e.g. `make PREFIX=$HOME` or `make PREFIX=/usr` to
install the files in `$HOME/bin` or `/usr/bin`, respectively.
To execute the programs ensure that the installation directory
is in your `PATH`.

## bibget: Extract BibTeX records to standalone file

The _bibget_ tool will process LaTeX `.aux` or `.bcf` files,
and use the data found there to output the required BibTeX records into
its standard output.
It is useful for extracting the (typically few) records required for
collaborating on a particular document from a (typically large)
personal collection of BibTeX records.

Here is how the same LaTeX file can use both the personal BibTeX files
and the shared generated one.

### BibTeX
Use the following in place of the `\bibliography` command.

```.tex
\ifx\mypubs\relax
\bibliography{mybibfile1,mybibfile2,mybibfile3,...}
\else
\bibliography{shared-refs,other-refs}
\fi % mypubs
```

By default this will cause the document to load and use the shared
BibTeX references.
To (re)generate the shared references run the following commands,
where `file` is the name of your LaTeX file.

```.sh
latex '\let\mypubs\relax \include{file}'
bibget file.aux >shared-refs.bib
```

### Biber
Use the following in place of the `\addbibresource` commands.

```.tex
\ifx\mypubs\relax
\addbibresource{myfile1.bib}
\addbibresource{myfile2.bib}
\addbibresource{....bib}
\else
\addbibresource{shared-refs.bib}
\addbibresource{other-refs.bib}
\fi % mypubs
```

By default this will cause the document to load and use the shared
BibTeX references.
To (re)generate the shared references run the following commands,
where `file` is the name of your LaTeX file.

```.sh
latex '\let\mypubs\relax \include{file}'
biber file
bibget file.bcf >shared-refs.bib
```

(Under the Windows `cmd32` shell replace the single quotes with double quotes.)

## bibtags: Create a vim/vi/Emacs tags file for bibliography records

The _bibtags_ tool will process the specified `.bib` files,
and will create in the current directory a file named `tags`,
which allows the quick navigation to bibliography entry from
your editor.
For example, in _vim_ you can do this by pressing `^]`,
when the cursor is on the entry's field.
