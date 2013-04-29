use strict;
use warnings;

package Crosslinker::Config;

use lib 'lib';
use Crosslinker::UserSettings;

use base 'Exporter';
our @EXPORT = ('get_mods', 'get_conf_value', 'connect_conf_db', 'add_conf', 'get_conf', 'delete_conf', 'update_conf');



######
#
# Config import functions
#
# Contains functions for the loading and saving of setting to and from the configuration database
#
######

sub _retry {
    my ($retrys, $func) = @_;
  attempt: {
        my $result;

        # if it works, return the result
        return $result if eval { $result = $func->(); 1 };

        # nah, it failed, if failure reason is not a lock, croak
        die $@ unless $@ =~ /database is locked/;

        # if we have 0 remaining retrys, stop trying.
        last attempt if $retrys < 1;

        sleep 100 / $retrys;
        $retrys--;
        redo attempt;
    }

    die "Attempts Exceeded $@";
}

sub get_conf {
    my ($dbh, $setting) = @_;

    my $sql = $dbh->prepare("SELECT * FROM setting WHERE type = ? ORDER BY name ASC");
    _retry 15, sub { $sql->execute($setting) };
    return $sql;

}

sub get_conf_value {
    my ($dbh, $rowid) = @_;

    my $sql = $dbh->prepare("SELECT * FROM setting WHERE rowid = ?");
    _retry 15, sub { $sql->execute($rowid) };
    return $sql;

}

sub get_mods {

    my ($table, $mod_type, $dbh) = @_;

    if (!defined $dbh) {
      if (sql_type eq 'mysql') {
	warn 'mysql';
	$dbh = DBI->connect("dbi:mysql:", "root", "crosslinker", { RaiseError => 1, AutoCommit => 1 });
	$dbh->do("create database if not exists settings");
	$dbh->disconnect;
	$dbh = DBI->connect("dbi:mysql:config", "root", "crosslinker", { RaiseError => 1, AutoCommit => 1 });
      } else {
	warn 'sqlite';
      $dbh = DBI->connect("dbi:SQLite:dbname=db/settings", "", "", { RaiseError => 1, AutoCommit => 1 });
      }
    }
    my $sql = $dbh->prepare("SELECT  * FROM modifications WHERE run_id = ? AND mod_type = ?");
    _retry 15, sub { $sql->execute($table, $mod_type) };
    return $sql;

}

sub delete_conf {
    my ($dbh, $rowid) = @_;

    my $sql = $dbh->prepare("DELETE FROM setting WHERE rowid = ?");
    _retry 15, sub { $sql->execute($rowid) };
    return $sql;

}

sub connect_conf_db {

    my $dbh;
    my $row_id_type;

    if (sql_type eq 'mysql') {
# 	warn 'mysql';
      $dbh = DBI->connect("dbi:mysql:", "root", "crosslinker", { RaiseError => 1, AutoCommit => 1 });
      $dbh->do("create database if not exists config");
      $dbh->disconnect;
      $dbh = DBI->connect("dbi:mysql:config", "root", "crosslinker", { RaiseError => 1, AutoCommit => 1 });
      $row_id_type = "MEDIUMINT NOT NULL AUTO_INCREMENT, PRIMARY KEY (rowid)";
    } else {
# 	warn 'sqlite';
	$dbh = DBI->connect("dbi:SQLite:dbname=db/config", "", "", { RaiseError => 1, AutoCommit => 1 });
	$row_id_type = "INTEGER PRIMARY KEY AUTOINCREMENT";
    }

    _retry 15, sub {
        $dbh->do(
            "CREATE TABLE IF NOT EXISTS setting (
						      rowid " . $row_id_type . ",
						      type TEXT,
						      id INT,
						      name TEXT,
						      setting1 TEXT,
						      setting2 TEXT,
						      setting3 TEXT,
						      setting4 TEXT,
						      setting5 TEXT
						      ) "
        );
    };

    my $count = $dbh->prepare('SELECT COUNT(*) FROM setting');
    $count->execute;
    my $n = $count->fetchall_arrayref()->[0][0];
 
    if ($n == 0) {
      _retry 15, sub {
	   $dbh->do("INSERT INTO setting VALUES(null, 'enzyme',0,'Trypsin','KR','P','C',0,0)");
	   $dbh->do("INSERT INTO setting VALUES(null, 'dynamic_mod',0,'Oxidation (M)',15.994915,'M',1,0,0)");
	   $dbh->do("INSERT INTO setting VALUES(null, 'fixed_mod',0,'Carbamidomethyl',57.02146,'C',0,0,0)");
	   $dbh->do("INSERT INTO setting VALUES(null, 'sequence',0,'PolIII','>PolIII\n MGSSHHHHHHSSGLEVLFQGPHMSEPRFVHLRVHSDYSMIDGLAKTAPLVKKAAALGMPALAITDFTNLCGLVKFYGAGHGAGIKPIVGADFNVQCDLLGDELTHLTVLAANNTGYQNLTLLISKAYQRGYGAAGPIIDRDWLIELNEGLILLSGGRMGDVGRSLLRGNSALVDECVAFYEEHFPDRYFLELIRTGRPDEESYLHAAVELAEARGLPVVATNDVRFIDSSDFDAHEIRVAIHDGFTLDDPKRPRNYSPQQYMRSEEEMCELFADIPEALANTVEIAKRCNVTVRLGEYFLPQFPTGDMSTEDYLVKRAKEGLEERLAFLFPDEEERLKRRPEYDERLETELQVINQMGFPGYFLIVMEFIQWSKDNGVPVGPGRGSGAGSLVAYALKITDLDPLEFDLLFERFLNPERVSMPDFDVDFCMEKRDQVIEHVADMYGRDAVSQIITFGTMAAKAVIRDVGRVLGHPYGFVDRISKLIPPDPGMTLAKAFEAEPQLPEIYEADEEVKALIDMARKLEGVTRNAGKHAGGVVIAPTKITDFAPLYCDEEGKHPVTQFDKSDVEYAGLVKFDFLGLRTLTIINWALEMINKRRAKNGEPPLDIAAIPLDDKKSFDMLQRSETTAVFQLESRGMKDLIKRLQPDCFEDMIALVALFRPGPLQSGMVDNFIDRKHGREEISYPDVQWQHESLKPVLEPTYGIILYQEQVMQIAQVLSGYTLGGADMLRRAMGKKKPEEMAKQRSVFAEGAEKNGINAELAMKIFDLVEKFAGYGFNKSHSAAYALVSYQTLWLKAHYPAEFMAAVMTADMDNTEKVVGLVDECWRMGLKILPPDINSGLYHFHVNDDGEIVYGIGAIKGVGEGPIEAIIEARNKGGYFRELFDLCARTDTKKLNRRVLEKLIMSGAFDRLGPHRAALMNSLGDALKAADQHAKAEAIGQADMFGVLAEEPEQIEQSYASCQPWPEQVVLDGERETLGLYLTGHPINQYLKEIERYVGGVRLKDMHPTERGKVITAAGLVVAARVMVTKRGNRIGICTLDDRSGRLEVMLFTDALDKYQQLLEKDRILIVSGQVSFDDFSGGLKMTAREVMDIDEAREKYARGLAISLTDRQIDDQLLNRLRQSLEPHRSGTIPVHLYYQRADARARLRFGATWRVSPSDRLLNDLRGLIGSEQVELEFD',0,0,0,0)");
	   $dbh->do("INSERT INTO setting VALUES(null, 'crosslinker',0,'BS2G-d4','K',96.0211296,114.0316942,'deuterium',4)");
	   $dbh->do("INSERT INTO setting VALUES(null, 'development',0,0,0,0,0,0,0)");
      };
   };



    return $dbh;
}

sub update_conf {
    my ($dbh, $type, $name, $setting1, $setting2, $setting3, $setting4, $setting5, $row_id) = @_;

    my $sql = $dbh->prepare(
        "UPDATE setting SET
						      type     = ?,
						      name     = ?,
						      setting1 = ?,
						      setting2 = ?,
						      setting3 = ?,
						      setting4 = ?,
						      setting5 = ?    
						WHERE rowid    = ?"
    );

    my $id = 0;
    _retry 15, sub { $sql->execute($type, $name, $setting1, $setting2, $setting3, $setting4, $setting5, $row_id) };
}

sub add_conf {
    my ($dbh, $type, $name, $setting1, $setting2, $setting3, $setting4, $setting5) = @_;

    my $sql = $dbh->prepare(
        "INSERT INTO setting 
						(
						      type,
						      id,
						      name,
						      setting1,
						      setting2,
						      setting3,
						      setting4,
						      setting5    
						 ) VALUES (?,?,?,?,?,?,?,?)"
    );

    my $id = 0;
    _retry 15, sub { $sql->execute($type, $id, $name, $setting1, $setting2, $setting3, $setting4, $setting5) };
}

1;

