# bibget: Extract BibTeX records to standalone file

The _bibget_ tool will process LaTeX `.aux` or `.bcf` files,
and use the data found there to output the required BibTeX records into
its standard output.
It is useful for extracting the (typically few) records required for
collaborating on a particular document from a (typically large)
personal collection of BibTeX records.

Here is how the same LaTeX file can use both the personal BibTeX files
and the shared generated one.

## BibTeX
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

## Biber
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
