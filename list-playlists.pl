use warnings;
use strict;

use Mac::iTunes::Library;
use Mac::iTunes::Library::Item;
use Mac::iTunes::Library::XML;
use URI::Escape;
use feature qw(say);

my $file = "/Users/Martin/Music/iTunes/iTunes Music Library.xml";

# Create library instance
my $library = Mac::iTunes::Library->new();
$library = Mac::iTunes::Library::XML->parse($file);

# Need to grab all playlists, then we'll look for the one that matches our name...
my %allPlaylists = $library->playlists();

foreach my $pl (values %allPlaylists) {
    eval {
        say "Playlist name: " . $pl->name;
        foreach my $i ($pl->items) {
            my $loc = uri_unescape($i->{Location});
            say $loc;
        }
        print "\n\n";
    }
}
