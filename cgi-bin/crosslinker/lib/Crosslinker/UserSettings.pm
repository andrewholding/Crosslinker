use strict;

package Crosslinker::UserSettings;
use base 'Exporter';
our @EXPORT = ('version', 'installed', 'sql_type', 'no_of_threads', 'is_verbose');

######
#
# User Settings
#
######

sub load_setting{
my ($setting_name, $setting) = @_;

open RC_FILE, "<", 'crosslinkerrc' or return $setting;
while (my $line = <RC_FILE>) {
	chomp $line;
	my @settings = split '=', $line;
	if ($settings[0] eq $setting_name) {$setting = $settings[1]}; 
}
close RC_FILE;
return $setting;

}

sub version {
    return '1.0.0';
}

sub installed {

my $setting = 'crosslinker'; 
$setting = load_setting ('installed', $setting);
return $setting;
}

sub sql_type {

my $setting = 'mysql'; #mysql or sqlite
$setting = load_setting ('sqltype', $setting);
return $setting;
}

sub no_of_threads {

my $setting = '4'; 
$setting = load_setting ('threads', $setting);
return $setting;
}

sub is_verbose {

my $setting = '0'; 
$setting = load_setting ('verbose', $setting);
return $setting;
}



1;



