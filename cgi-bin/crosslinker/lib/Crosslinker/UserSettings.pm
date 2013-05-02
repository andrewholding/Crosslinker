use strict;

package Crosslinker::UserSettings;
use base 'Exporter';
our @EXPORT = ('version', 'installed', 'sql_type');

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

1;

