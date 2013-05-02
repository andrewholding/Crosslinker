use strict;

package Crosslinker::UserSettings;
use base 'Exporter';
our @EXPORT = ('version', 'installed', 'sql_type', 'no_of_threads');

######
#
# User Settings
#
######


sub version {
    return '1.0.0';
}

sub installed {
    return 'crosslinker';
}

sub sql_type {


return 'mysql'; #mysql or sqlite
}

sub no_of_threads {

return 4;
}


1;



