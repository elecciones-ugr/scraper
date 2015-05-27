#!/usr/bin/env perl

use Modern::Perl;
use autodie;
use utf8;

use LWP::Simple;
use Mojo::DOM;
use File::Slurp::Tiny qw(write_file read_file);
use JSON;

my $url = shift || "file:muestra.html";
my $output_fn = shift || "results";

# Comprueba los resultados actuales
my $old_results = decode_json read_file "$output_fn.json";

# Descarga los nuevos resultados
my $dom = Mojo::DOM->new( get $url );

die "No puedo descargarme $url" if !$dom;

my ($porcentaje) = ( $dom->all_text() =~ /del\s+(\d+\.\d+)\%/ );

if ( $porcentaje != $old_results->{'Escrutado'} ) {
  my $candidaturas = $dom->find("table.con_borde");

  my %results = ( Escrutado => $porcentaje,
		  Resultados => {} );
  
  my @results_csv = (["Candidato", "Sector","Coeficiente", "Votos","Resultado"]);
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
      my @column_values = ();
      while ( my $l = shift @these_cols ) {
	my $this_result = shift @$res;
	$this_result =~ s/,/./g;
	$results_sector->{$l} = $this_result;
	push @column_values, $this_result;
      }
      push @{$results{'Resultados'}{$who}{'Sector'}}, $results_sector;
      push @results_csv, [$who, @column_values];
    }
  }
  
  my $tweet = "#eleccionesugr Escrutado: $porcentaje%\n";
  my @cuadraicos=('▥', '▧');
  for my $c (keys %{$results{'Resultados'}} ) {
      my $cuadraico = shift @cuadraicos;
      my $total = $results{'Resultados'}{$c}{'Total'};
      $tweet .= cuadraicos($total, $cuadraico)
	." $total% $c\n";
  }

  #Ahora tweetea
  `./twcli.py "$tweet"`;

  # Escribe ficheros
  my $output = encode_json \%results;
  write_file("$output_fn.csv", join("\n",map( join("; ", @$_), @results_csv)));
  write_file("$output_fn.json",$output);
  my $jsonp = "parse_results( $output )";
  write_file("$output_fn.jsonp",$jsonp);

} else {
  say "Mismos resultados";
}

sub cuadraicos {
    my $porcentaje = shift || 100;
    my $cuadraico = shift || '▤';
    my $offset = $porcentaje / 10;
    return $cuadraico x $offset;
}
