#!/usr/bin/perl
use warnings;
use strict;

use Data::Dumper;
use File::Basename;
use Getopt::Long;
use Mac::iTunes::Library;
use Mac::iTunes::Library::Item;
use Mac::iTunes::Library::XML;
use URI::Escape;
use feature qw(say);

my $itunesfile;
my $output_dir = './output-disc.fpbf/';
my $playlistName = '';

my $dir = '';
my $dirOut = '';

GetOptions(
    'd|directory=s' => \$dir,
    'name=s'        => \$dirOut,
    'o|output=s'    => \$output_dir,
    'p|playlist=s'  => \$playlistName,
    'i|itunesxml=s' => \$itunesfile,
);

# Trailing slashes are assumed later on, add here if not set
$dirOut .= '/' if ($dirOut && $dirOut !~ m#/$#);
$dir .= '/' if ($dir && $dir !~ m#/$#);

my @in;
if ($playlistName) {
    unless ($itunesfile) {
        my $username = `whoami`;
        chomp($username);
        $itunesfile = "/Users/$username/Music/iTunes/iTunes Music Library.xml";
    }
    # Create library instance
    my $library = Mac::iTunes::Library->new();
    $library = Mac::iTunes::Library::XML->parse($itunesfile);

    # Need to grab all playlists, then we'll look for the one that matches our name...
    my %allPlaylists = $library->playlists();

    # Find our specific playlist
    my ($pl) = grep { $_->name eq $playlistName } (values %allPlaylists);
    die("Couldn't find playlist $playlistName") unless $pl;

    foreach my $i ($pl->items) {
        my $loc = uri_unescape($i->{Location});
        push(@in, $loc);
    }

    $dirOut ||= $playlistName;

} elsif ($dir) {
    # Find files in supplied directory
    opendir(DIR, $dir) or die $!;
    my @files = grep { /^[^\.]/ && -f "$dir/$_" } readdir(DIR);
    foreach my $file (@files) {
        push(@in, $dir . $file);
    }
    closedir(DIR);
}

if (scalar @in == 0) {
    warn "No songs to work with. Supply a playlist name (-p) or input directory (-d).\n";
}

$output_dir .= $dirOut;
$output_dir .= '/' if ($output_dir && $output_dir !~ m#/$#);
system('mkdir', '-p', $output_dir) unless (-e $output_dir);
warn "Working with " . scalar @in . " music files, outputting to => $output_dir\n";

# Copy or convert each file...
my $count = scalar @in;
my $k = 1;
foreach my $loc (@in) {
    my ($name,$path) = fileparse( $loc );
    $path =~ s#^file://##;

    my $new_name = $name;
    $new_name =~ s/\.[^\.]+$/.mp3/ if $name !~ /\.mp3$/;
    my $out_full = $output_dir . $new_name;

    say "Processing $k / $count => $path$name";

    if ($name =~ m/\.mp3$/) {
        unless (-e $out_full) {
            # say "$out_full doesn't exist";
            # MP3 already, copy straight to disc
            system("cp","-n","$path$name","$output_dir");
        }
    } else {
        if (! -e $out_full) {
            # ffmpeg to convert, output straight to disk
            # say qq{ffmpeg -loglevel error -i "$path$name" "$out_full"};
            system("ffmpeg", "-loglevel", "error", "-i", "$path$name", "$out_full");
        }
    }
    $k++;
}
