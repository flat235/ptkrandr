#!/usr/bin/perl

use warnings;
use strict;

use Tk;

my $script = $0;

my @lines = `xrandr`;
my $screen = -1;
my @screens;
my $res = 0;
my $monitor = 0;


for my $line (@lines){
	
	if($line =~ /^Screen (\d+):/){
		$screen = $1;
	}
	elsif($line =~ /^\s*(\d+x\d+\S*)/){
		$screens[$screen]->{$monitor}->{'resolutions'}->[$res] = $1;
		$res++;
	}
	elsif ($line =~ /^(\S+)\s+connected\s+(\d+x\d+)/){
		$monitor = $1;
		$screens[$screen]->{$monitor}->{'currentresolution'} = $2;
		$res = 0;
	}
	else{
		$monitor = 0;
		$res = 0;
	}
}

$screen = 0;
my $mw = MainWindow->new(-title => 'Monitor Configuration');

for my $curscreen (@screens) {

	my $frame = $mw->Frame(
		-label => 'Screen ' . "$screen",
		-borderwidth => 1,
		-relief => 'solid');
	$screen++;

	for my $curmon (keys($curscreen)){

		my $subframe = $frame->Frame(
			-label => $curmon . ': ' . $curscreen->{$curmon}->{'currentresolution'},
			-borderwidth => 1,
			-relief => 'raised');

		$subframe->Button(
			-text => 'Auto dectect',
			-command => sub {
				system('xrandr --output ' . $curmon . ' --auto');
				exec($script);
			})->pack(-side => 'top');

		for my $curres (@{$curscreen->{$curmon}->{'resolutions'}}){

			$subframe->Button(
				-text => "$curres",
				-command => sub {
					system('xrandr --output ' . $curmon . ' --mode ' . $curres);
					exec $script;
				})->pack(-side => 'top');
		}

		$subframe->pack(-side => 'left');
	}

	$frame->pack(-side => 'left');
}
MainLoop;
