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
    return '0.9.3';
}

sub installed {
    return 'crosslinker';
}

sub sql_type {


return 'sqlite'; #mysql or sqlite
}

1;

