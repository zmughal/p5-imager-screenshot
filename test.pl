#!/usr/bin/env perl
# PODNAME: «name of script»
# ABSTRACT: «description»

use FindBin;
use lib "$FindBin::Bin/../lib";
use lib "$FindBin::Bin/../lo";

use Test::Most;
use Imager::Screenshot;
# brew install imagemagick

sub main {
	# open browser <https://upload.wikimedia.org/wikipedia/commons/f/ff/Solid_blue.svg>
	my $img = Imager::Screenshot::screenshot( darwin => 0 );
	$img->write( file => 'imager-screenshot.png' );

	system(qw(screencapture -t png), 'screen-capture.png');

	system(qw(mogrify -crop 540x630+0+96), $_) for ('imager-screenshot.png', 'screen-capture.png');

	$img = Imager->new( file => 'imager-screenshot.png' );
	my $sc = Imager->new( file => 'screen-capture.png' );


	my $diff = $img->difference( other => $sc );
	$diff->write( file => 'diff.png' );

	system(<<EOF);
compare screen-capture.png imager-screenshot.png -compose Difference -colorspace rgb -verbose info: | sed -n '/statistics:/,/^  [^ ]/p'
EOF


	my $colors = $img->getcolorusagehash;
	my $blue_color = pack("CCC", 0x00, 0x00, 0xFF );
	#$blue_color = pack("CCC", 0x05, 0x33, 0xFF) if $^O eq 'darwin';
	ok exists $colors->{ $blue_color  } && $colors->{ $blue_color  } > 200, 'has the blue color we are looking for: #0000FF';
	done_testing;
}

main;

