#!/usr/bin/env perl

use Modern::Perl;
use autodie;

use LWP::Simple;
use Mojo::DOM;
use JSON;

my $url = shift || "file:muestra.html";

my $dom = Mojo::DOM->new( get $url );

die "No puedo descargarme $url" if !$dom;

my $candidaturas = $dom->find("table.unnamed1");

my %results;
for my $c (@$candidaturas ) {
  my $rows = $c->find("table tr");
  my $who_ref = shift @$rows ;
  my $who = $who_ref->all_text();
  my $what = shift @$rows ;
  my $total_ref = pop @$rows;
  my $cols = $what->find('div')->map('text');
  $results{$who}= [{ 'Total' => $total_ref->all_text()}];
  for my $r ( @$rows ) {
    my @these_cols = @$cols;
    my $res = $r->find('td')->map('text');
    my $results_sector = {};
    while ( my $l = shift @these_cols ) {
      $results_sector->{$l} = shift @$res;
    }
    push @{$results{$who}}, $results_sector;
  }
}

say encode_json \%results;
