#!/usr/bin/perl

use warnings;
#use strict;

use Tk;

my $script = $0;

my @lines = `xrandr`;
my $screen = -1;
my @screens;
my $state = 0;
my $res = 0;
my $monitor = 0;


for my $line (@lines){
	
	if($line =~ /^Screen (\d+):/){
		$screen = $1;
	}
	elsif($line =~ /^\s*(\d+x\d+\S*)/){
		$screens[$screen]->{$monitor}->[$res] = $1;
		$res++;
	}
	elsif ($line =~ /^(\S+)\s+connected/){
		$monitor = $1;
		$res = 0;
	}
	else{
		$monitor = 0;
		$res = 0;
	}
}

$mw = MainWindow->new(-title => 'Monitor Konfiguration');
$screen = 0;
for my $curscreen (@screens) {
	my $frame = $mw->Frame;
	$frame->Label(-text => 'Screen ' . "$screen")->pack;
	for my $curmon (keys($screens[$screen])){
		my $subframe = $frame->Frame;
		$subframe->Label(-text => $curmon)->pack;
		$subframe->Button(-text => 'Automatisch erkennen', -command => sub { system('xrandr --output ' . $curmon . ' --auto'); exec($script);})->pack(-side => 'top');
		for my $curres (@{$screens[$screen]->{$curmon}}){
			$subframe->Button(-text => "$curres", -command => sub { system('xrandr --output ' . $curmon . ' --mode ' . $curres); exec $script;})->pack(-side => 'top');
		}
		$subframe->pack(-side => 'left');
	}
	$frame->pack(-side => 'left');
	$screen++;
}
$mw->Button(-text => 'Beenden', -command => sub { exit; })->pack(-side => 'bottom');
MainLoop;
