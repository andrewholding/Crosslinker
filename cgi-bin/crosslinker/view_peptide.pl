#!/usr/bin/perl -w

########################
#                      #
# Modules	       #
#                      #
########################

use strict;
use CGI;
use CGI::Carp qw ( fatalsToBrowser );
use DBI;

use lib 'lib';
use Crosslinker::HTML;
use Crosslinker::Results;
use Crosslinker::Constants;
use Crosslinker::Data;

########################
#                      #
# Import CGI Varibles  #
#                      #
########################

my $query   = new CGI;
my $table   = $query->param('table');
my $peptide = $query->param('peptide');

########################
#                      #
# Connect to database  #
#                      #
########################

my $settings_dbh = connect_settings;

my $settings_sql = $settings_dbh->prepare("SELECT name FROM settings WHERE name = ?");
$settings_sql->execute($table);
my @data = $settings_sql->fetchrow_array();
if ($data[0] != $table) {
    print "Content-Type: text/plain\n\n";
    print "Cannont find results database";
    exit;
}

my $results_dbh =      connect_db_results($table);

########################
#                      #
# Load Settings        #
#                      #
########################

my $settings = $settings_dbh->prepare("SELECT * FROM settings WHERE name = ?");
$settings->execute($table);
my (
    $name,         $desc,  $cut_residues, $protein_sequences, $reactive_site, $mono_mass_diff,
    $xlinker_mass, $decoy, $ms2_da,       $ms1_ppm,           $is_finished,   $mass_seperation
) = $settings->fetchrow_array;
$settings->finish();
$settings_sql->finish();
$settings_dbh->disconnect();

########################
#                      #
# Constants            #
#                      #
########################
my (
    $mass_of_deuterium, $mass_of_hydrogen, $mass_of_proton,     $mass_of_carbon12,
    $mass_of_carbon13,  $no_of_fractions,  $min_peptide_length, $scan_width
) = constants;

########################
#                      #
# Summary Gen          #
#                      #
########################

print_page_top_bootstrap("Peptide - $peptide");
if ($is_finished == '0') {
    print '<div style="text-align:center"><h2 style="color:red;">Warning: Data analysis not finished</h2></div>';
}

print_heading('Top Scoring Crosslink Matches');

print "<div style='padding:1em;'><a href='view_summary.pl?table=$table'>Return to Summary</a></div>";

my $top_hits = $results_dbh->prepare("SELECT * FROM results WHERE name=? AND fragment LIKE ? ORDER BY score DESC")
  ;    #nice injection problem here, need to sort
$top_hits->execute($table, $peptide);
print_results(
              $top_hits,         $mass_of_hydrogen, $mass_of_deuterium, $mass_of_carbon12,
              $mass_of_carbon13, $cut_residues,     $protein_sequences, $reactive_site,
              $results_dbh,      $xlinker_mass,     $mono_mass_diff,    $table,
              $mass_seperation,  1,                 1,                  0,
              0,                 '',		    '',			'',
              '',                '',	    	    '',			$settings_dbh

);
print_page_bottom_bootstrap;
$top_hits->finish();
exit;
