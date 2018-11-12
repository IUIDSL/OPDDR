#!/usr/bin/env perl

while (<>)
{
  next if /^@/;
  next if /^$/;
  s/<substance\/([^>]*)>/substance:$1/g ;
  s/<compound\/([^>]*)>/compound:$1/g ;
  s/<endpoint\/([^>]*)>/endpoint:$1/g ;
  s/<measuregroup\/([^>]*)>/measureg:$1/g ;
  s/<bioassay\/([^>]*)>/bioassay:$1/g ;
  s/<source\/([^>]*)>/source:$1/g ;
  s/<descriptor\/([^>]*)>/descr:$1/g ;
  s/<synonym\/([^>]*)>/syno:$1/g ;
  s/<reference\/([^>]*)>/reference:$1/g ;
  s/<vocabulary#([^>]*)>/vocabulary:$1/g ;

  s#<http://purl.obolibrary.org/obo/([^>]*)>#obo:$1#g ;
  s#<http://purl.org/dc/terms/([^>]*)>#dcterms:$1#g ;
  s#<http://semanticscience.org/resource/([^>]*)>#sio:$1#g ;
  s#<http://www.bioassayontology.org/bao\#([^>]*)>#bao:$1#g ;

  s#<http://www.w3.org/2000/01/rdf-schema\#([^>]*)>#rdfs:$1#g ;
  s#<http://www.w3.org/2001/XMLSchema\#([^>]*)>#xsd:$1#g ;

  print $_;
}
