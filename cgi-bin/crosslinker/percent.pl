#!/usr/bin/perl -w

use strict;
use CGI;
use CGI::Carp qw ( fatalsToBrowser );
use DBI;

use lib 'lib';
use Crosslinker::Data;

my ($dbh_memory, $dbh) = connect_db;
# my $dbh = DBI->connect("dbi:SQLite:dbname=db/settings", "", "", { RaiseError => 1, AutoCommit => 1 });

$dbh_memory->disconnect;

create_settings($dbh);
print "Content-type: text/html\n\n";

my $query = new CGI;
my $table = $query->param('table');

my $table_list = $dbh->prepare("SELECT name, description, finished FROM settings WHERE name = ?");
$table_list->execute($table);

my $state;

while (my $table_name = $table_list->fetchrow_hashref) {
    if ($table_name->{'finished'} == -1) {
        $state = '<span class="label label-success">Done</span>';
    } elsif ($table_name->{'finished'} == -2) {
        $state = '<span class="label">Waiting...</span>';
    } elsif ($table_name->{'finished'} == -3) {
        $state = '<span class="label label-info">Starting...</span>';
    } elsif ($table_name->{'finished'} == -4) {
        $state = '<span class="label label-warning">Aborted</span>';
    } elsif ($table_name->{'finished'} == -5) {
        $state = '<span class="label label-important">Failed</span>';
    } elsif ($table_name->{'finished'} == -6) {
        $state = '<span class="label label-info">Importing...</span>';
    }

    else {
        $state =  '<span class="label">' . $table_name->{'finished'} * 100 . "% </span>";
    }
}
print $state;