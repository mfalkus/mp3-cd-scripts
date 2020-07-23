# Who is this repo for?

Have an old car that will play MP3 CDs? (e.g. an Audi Symphony CD player?)

Have a folder full of non-MP3 files?

This repo might be for you!

It's aimed at Mac OS X users. You'll need to be a little comfortable on the
command line. Start by installing `ffmpeg` and the Perl module for iTunes
library access:

```
brew install ffmpeg
# and
cpan install Mac::iTunes::Library
```

Then test you can access your iTunes library with the `list-playlists.pl` file.
Use Terminal to navigate to this repo and run `perl list-playlists.pl`.

Check you can also run `ffmpeg`, e.g. from Terminal run `ffmpeg -h`.

If both work you are in good shape!

# Running It

Two options, either from an iTunes playlist or a directory of input files:

```
./make-mp3-cd.pl -p 'playlist name' -o output_directory.fpbf
```


```
./make-mp3-cd.pl -d ../my-song-directory/here/ -o output_directory.fpbf
```

For further details see this blog post.
