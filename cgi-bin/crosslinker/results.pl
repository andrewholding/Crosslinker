#!/usr/bin/perl -w

use strict;
use CGI;
use CGI::Carp qw ( fatalsToBrowser );
use DBI;

use lib 'lib';
use Crosslinker::HTML;
use Crosslinker::Data;
use Crosslinker::UserSettings;


my ($dbh_memory, $dbh) = connect_db;
# my $dbh = DBI->connect("dbi:SQLite:dbname=db/settings", "", "", { RaiseError => 1, AutoCommit => 1 });

$dbh_memory->disconnect;

create_settings($dbh);




print_page_top_bootstrap('Results', 1);

print_heading('Results');
print "<br/><table class='table table-striped'><tr><td colspan='4'>Results ID</td><td colspan='7'></td></tr>";


# my $table_list = $dbh->prepare("SELECT name, description, finished FROM settings where finished = -3 or finished >= 0 ");
# $table_list->execute();
# my $sample_in_progress = $table_list->fetchrow_hashref;
# 
# if (defined $sample_in_progress->{'name'}) {
#     print "<div class='alert alert-info'>
#       <h4>Current Progress</h4><p>Sample $sample_in_progress->{'name'} - '$sample_in_progress->{'description'}'.</p>
#     ";
# 
# my $scored = 0;
# if ($sample_in_progress->{'finished'} > 0) {$scored = $sample_in_progress->{'finished'} * 100};
# 
# print '
# <p><div class="progress progress-striped active">
#   <div class="bar" style="width:', $scored,'%;"></div>
# </div></p></div>', $sample_in_progress->{'start_percentage'};
# 
# }

 print '
 <div id="wrapper"> 
     <div id="progressbar"></div>
 </div>';


my $table_list = $dbh->prepare("SELECT name, description, finished FROM settings  ORDER BY length(name) DESC, name DESC ");
$table_list->execute();

print '<form name="combined" action="view_combined.pl" method="GET">';

while (my $table_name = $table_list->fetchrow_hashref) {
    my $state;
    if ($table_name->{'finished'} == -1) {
        $state = "<div>". '<span class="label label-success">Done</span>';
    } elsif ($table_name->{'finished'} == -2) {
        $state = "<div class='percentage' data-result='$table_name->{'name'}'>". '<span class="label">Waiting...</span>';
    } elsif ($table_name->{'finished'} == -3) {
        $state = "<div class='percentage' data-result='$table_name->{'name'}'>". '<span class="label label-info">Starting...</span>';
    } elsif ($table_name->{'finished'} == -4) {
        $state = "<div>". '<span class="label label-warning">Aborted</span>';
    } elsif ($table_name->{'finished'} == -5) {
        $state = "<div>". '<span class="label label-important">Failed</span>';
    } elsif ($table_name->{'finished'} == -6) {
        $state = "<div class='percentage' data-result='$table_name->{'name'}'>" .'<span class="label label-info">Importing...</span>';
    }

    else {
        $state =  "<div class='percentage' data-result='$table_name->{'name'}'>" . '<span class="label">' . $table_name->{'finished'} * 100 . "%</span>";
    }

print '<tr><td>';

 if (sql_type ne 'mysql' )   { print '<input type="checkbox" name="' . $table_name->{'name'} . '" value="true"></input>'; }


print ' </td><td>',  $table_name->{'name'}, '</td><td><a href="rename.pl?table=' . $table_name->{'name'} . '">' . $table_name->{'description'} . "</td><td>";

#     if ($table_name->{'finished'} != -1 && $table_name->{'finished'} != -4 && $table_name->{'finished'} != -5) {
#         print '<iframe style="border: 0px; width:8em; height:1.29em; overflow-y: hidden;" src="status-iframe.pl?table=',
#           $table_name->{'name'}, '">', $state, '</iframe>',
#           ;
#     } else {
        print "$state</div>";
#     }

    print
"</td><td> <a href='view_summary.pl?table=$table_name->{'name'}'>Summary</a> </td><td> <a href='view_pymol.pl?table=$table_name->{'name'}'>Pymol</a> </td><td> <a href='view_paper.pl?table=$table_name->{'name'}'>Sorted</a> </td><td> <a href='view_report.pl?table=$table_name->{'name'}' >Report</a></td><td><a href='view_txt.pl?table=$table_name->{'name'}'>CSV</a></td><td><a class='btn btn-danger' href='delete.pl?table=$table_name->{'name'}' >Delete</a> <a class='btn btn-warning' href='abort.pl?table=$table_name->{'name'}' >Abort</a></td></tr>";
}

print "</table>";

print
'<div style="width: 20em; margin: auto; padding:1em;">';

 if (sql_type ne 'mysql' )   { print '<input class="btn btn-primary" type="submit" value="Combine">&nbsp';}
print '<a class="btn" href="view_log.pl">View Log</a>';
print '&nbsp<a class="btn" href="clear_log.pl">Clear Log</a></form></div>';
print_page_bottom_bootstrap;
$dbh->disconnect();
exit;
