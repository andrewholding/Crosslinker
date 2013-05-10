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

my $table_list = $dbh->prepare("SELECT name, description, finished, status, percent FROM settings INNER JOIN status on name = run_id where  settings.finished = -3 or settings.finished >= 0   ");
$table_list->execute();
my $sample_in_progress = $table_list->fetchrow_hashref;

if (defined $sample_in_progress->{'name'}) {
    print "<div class='alert alert-info'>
      <h4>Current Progress</h4><p>Sample $sample_in_progress->{'name'} &mdash; '$sample_in_progress->{'description'}' &mdash; $sample_in_progress->{'status'} ...</p>
    ";

my $scored = 0;
$scored = $sample_in_progress->{'percent'};

print '
<p><div class="progress progress-striped ">
  <div class="bar" style="width:', $scored,'%;"></div>
</div></p></div>';

}
