#!/usr/bin/env perl

use strict;
use warnings;
use feature ":5.10";
use Tkx;

our $VERSION = "0.01";

my $IS_AQUA = Tkx::tk_windowingsystem() eq "aqua";

my $mw = Tkx::widget->new(".");

$mw->configure(-menu => create_menu($mw));

Tkx::wm_title($mw, "eiek");
Tkx::wm_minsize($mw, 800, 600);

Tkx::MainLoop();

sub create_menu {
	my $mw = shift;
	my $menu = $mw->new_menu;

	my $file = $menu->new_menu(-tearoff => 0);
	$menu->add_cascade(
		-label => "File",
		-underline => 0,
		-menu => $file,
	);

	$file->add_command(
		-label => "New repository",
		-underline => 0,
		-accelerator => "Ctrl+N",
		-command => \&new,
	);
	$mw->g_bind("<Control-n>", \&new);

	$file->add_command(
		-label => "Exit",
		-underline => 1,
		-command => [\&Tkx::destroy, $mw],
	) unless $IS_AQUA;

	my $help = $menu->new_menu(
		-name => "help",
		-tearoff => 0,
	);
	$menu->add_cascade(
		-label => "Help",
		-underline => 0,
		-menu => $help,
	);

	$help->add_command(
		-label => "About eiek",
		-command => \&about,
	);

	return $menu;
}

sub about {
	Tkx::tk___messageBox(
		-parent => $mw,
		-title => "About eiek",
		-type => "ok",
		-icon => "info",
		-message => "eiek v$VERSION\n" .
			"Licensed under GPLv2",
	);
}
