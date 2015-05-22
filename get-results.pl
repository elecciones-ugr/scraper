#!/usr/bin/env perl

use Modern::Perl;
use autodie;

use LWP::Simple;
use Mojo::DOM;
use File::Slurp::Tiny qw(write_file);
use JSON;

my $url = shift || "file:muestra.html";
my $output_fn = shift || "results";

my $dom = Mojo::DOM->new( get $url );

die "No puedo descargarme $url" if !$dom;

my ($porcentaje) = ( $dom->all_text() =~ /del\s+(\d+\.\d+)\%/ );
my $candidaturas = $dom->find("table.unnamed1");

my %results = ( Escrutado => $porcentaje,
		Resultados => {} );
for my $c (@$candidaturas ) {
  my $rows = $c->find("table tr");
  my $who_ref = shift @$rows ;
  my $who = $who_ref->all_text();
  my $what = shift @$rows ;
  my $total_ref = pop @$rows;
  my $cols = $what->find('div')->map('text');
  my $total = $total_ref->all_text();
  $total =~ s/,/./;
  $results{'Resultados'}{$who} = { 'Total' => $total,
				   'Sector' => [] };
  for my $r ( @$rows ) {
    my @these_cols = @$cols;
    my $res = $r->find('td')->map('text');
    my $results_sector = {};
    while ( my $l = shift @these_cols ) {
	my $this_result = shift @$res;
	$this_result =~ s/,/./g;
	$results_sector->{$l} = $this_result;
    }
    push @{$results{'Resultados'}{$who}{'Sector'}}, $results_sector;
  }
}

my $output = encode_json \%results;

write_file("$output_fn.json",$output);
my $jsonp = "parse_results( $output )";
write_file("$output_fn.jsonp",$jsonp);
