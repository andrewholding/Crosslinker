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
use Crosslinker::Config;

########################
#                      #
# Import CGI Varibles  #
#                      #
########################

my $query = new CGI;
my $table = $query->param('table');

########################
#                      #
# Connect to database  #
#                      #
########################

my $results_dbh  = DBI->connect( "dbi:SQLite:dbname=db/results",  "", "", { RaiseError => 1, AutoCommit => 1 } );
my $settings_dbh = DBI->connect( "dbi:SQLite:dbname=db/settings", "", "", { RaiseError => 1, AutoCommit => 1 } );

########################
#                      #
# Load Settings        #
#                      #
########################

my $settings = $settings_dbh->prepare("SELECT * FROM settings WHERE name = ?");
$settings->execute($table);
my ( $name, $desc, $cut_residues, $protein_sequences, $reactive_site, $mono_mass_diff, $xlinker_mass, $decoy, $ms2_da, $ms1_ppm, $is_finished ) =
  $settings->fetchrow_array;
$settings->finish();
$settings_dbh->disconnect();

########################
#                      #
# Constants            #
#                      #
########################

my ( $mass_of_deuterium, $mass_of_hydrogen, $mass_of_proton, $mass_of_carbon12, $mass_of_carbon13, $no_of_fractions, $min_peptide_length, $scan_width ) =
  constants;

########################
#                      #
# Summary Gen          #
#                      #
########################

print_page_top('Report');
print "<Table>
<tr><td style='font-weight: bold;'>Name:</td><td>$name</td><td style='font-weight: bold;'>Description</td><td>$desc</td></tr>
<tr><td style='font-weight: bold;'>Cut:</td><td>$cut_residues</td><td style='font-weight: bold;'>Xlink Site</td><td>$reactive_site</td></tr>
<tr><td style='font-weight: bold;'>Xlinker Mass:</td><td>$xlinker_mass</td><td style='font-weight: bold;'>Monolink</td><td>$mono_mass_diff</td></tr></table><hr/>";

if ( $is_finished != '-1' ) {
   print '<div style="text-align:center"><h2 style="color:red;">Warning: Data analysis not finished ' . $is_finished . '</h2></div>';
}

my $top_hits =
  $results_dbh->prepare( "SELECT * FROM results WHERE name=? AND fragment LIKE '%-%' ORDER BY score DESC" );    #nice injection problem here, need to sort
$top_hits->execute($table);
print_report( $top_hits,      $mass_of_hydrogen, $mass_of_deuterium, $mass_of_carbon12, $mass_of_carbon13, $cut_residues, $protein_sequences,
              $reactive_site, $results_dbh,      $xlinker_mass,      $mono_mass_diff,   $table,            1 );

print_page_bottom;
$top_hits->finish();
$results_dbh->disconnect();
exit;
