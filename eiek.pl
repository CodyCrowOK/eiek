#!/usr/bin/env perl

use strict;
use warnings;
use feature ":5.10";
use Tkx;
use File::PathConvert qw(abs2rel);

our $VERSION = "0.01";
my $cwd;

my $IS_AQUA = Tkx::tk_windowingsystem() eq "aqua";

my $mw = Tkx::widget->new(".");

#Create the menu bar
$mw->configure(-menu => create_menu($mw));
my $splash = $mw->new_ttk__frame(-padding => "3 3 12 12");
my $content = $mw->new_ttk__frame(-padding => "3 3 12 12");

#Prompt the user, asking if they'd like to load a repo or create a new one.
my $loadrepo_button = $splash->new_button(
	-text => "Load repository",
	-command => sub {
		my $dirname = Tkx::tk___chooseDirectory();
		if ($dirname) {
			$cwd = $dirname;
			chdir $cwd;
			&destroy_splash;
		}
	},
);

my $newrepo_button = $splash->new_button(
	-text => "New repository",
	-command => sub {
		my $dirname = Tkx::tk___chooseDirectory();
		if ($dirname) {
			$cwd = $dirname;
			chdir $cwd;
			&eie_init;
			&destroy_splash;
		}
	},
);

$splash->g_place(-relx => 0, -rely => 0, -relwidth => 1.0, -relheight => 1.0);
$newrepo_button->g_place(-relx => 0, -rely => 0, -relwidth => 1.0, -relheight => .5);
$loadrepo_button->g_place(-relx => 0, -rely => .5, -relwidth => 1.0, -relheight => .5);

$mw->g_wm_title("eiek");
$mw->g_wm_geometry("800x600+25+50");

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

sub destroy_splash {
	$splash->g_destroy();
	&load_main;
}

sub load_main {
	my $add_button = $content->new_button(
		-text => "Add files to be committed",
		-command => sub {
			my $files = Tkx::tk___getOpenFile(
				-title => "Add files",
				-multiple => 1,
			);
			eie_add($files);
		},
	);
	my $clear_button = $content->new_button(
		-text => "Clear files to be committed",
		-command => sub {
			&eie_clear;
		},
	);
	my $commit_button = $content->new_button(
		-text => "Commit queued files",
		-command => sub {
			&eie_commit;
		},
	);
	my $list_button = $content->new_button(
		-text => "List all commits containing a particular file",
		-command => sub {
			my $file = Tkx::tk___getOpenFile(
				-title => "List for which file?",
			);
			eie_list($file);
		},
	);
	my $revert_button = $content->new_button(
		-text => "Revert a file to its contents at a particular commit",
		-command => sub {
			
		},
	);
	my $destroy_button = $content->new_button(
		-text => "Destroy eie repository",
		-command => sub {
			
		},
	);
	$content->g_place(-relx => 0, -rely => 0, -relwidth => 1.0, -relheight => 1.0);
	$add_button->g_place(-relx => 0, -rely => 0, -relwidth => 1.0, -relheight => .1666666666667);
	$clear_button->g_place(-relx => 0, -rely => .1666666666667, -relwidth => 1.0, -relheight => .1666666666667);
	$commit_button->g_place(-relx => 0, -rely => .3333333333333, -relwidth => 1.0, -relheight => .1666666666667);
	$list_button->g_place(-relx => 0, -rely => .5, -relwidth => 1.0, -relheight => .1666666666667);
	$revert_button->g_place(-relx => 0, -rely => .6666666666667, -relwidth => 1.0, -relheight => .1666666666667);
	$destroy_button->g_place(-relx => 0, -rely => .8333333333333, -relwidth => 1.0, -relheight => .1666666666667);

}

sub eie_init {
	system ('eie', 'init');
}

sub eie_add {
	my $i = 0;
	while (@_) {
		my $f = shift;
		my @files = split(/ /, $f);
		foreach my $file (@files) {
			$i++;
			system ('eie', 'add', abs2rel($file, $cwd));
		}
	}
	Tkx::tk___messageBox(
		-parent => $mw,
		-title => "Add Files",
		-type => "ok",
		-icon => "info",
		-message => "$i Files added successfully.",
	);
}

sub eie_clear {
	system ('eie', 'clear');
	Tkx::tk___messageBox(
		-parent => $mw,
		-title => "Clear",
		-type => "ok",
		-icon => "info",
		-message => "Queue cleared successfully.",
	);
}

sub eie_commit {
	system ('eie', 'commit');
	Tkx::tk___messageBox(
		-parent => $mw,
		-title => "Commit",
		-type => "ok",
		-icon => "info",
		-message => "All queued files committed successfully.",
	);
}

sub eie_list {
	my $file = shift;
	$file = abs2rel($file, $cwd);
	my $ret = `eie list $file`;
	my @commits = split(/\n/, $ret);
	shift @commits;
	
	my $window = $mw->new_toplevel;
	$window->g_wm_title("List");
	$window->g_wm_geometry("300x300+100+250");
	#This is necessary for "Tcl formatted lists":
	my $cnames = ''; foreach my $i (@commits) {$cnames = $cnames . ' {' . $i . '}';};
	my $lbox = $window->new_tk__listbox(-height => 10, -listvariable => \$cnames);

	my $copy_button = $window->new_button(
		-text => "Copy selected commit ID to clipboard.",
		-command => sub {
			my $selected = $commits[$lbox->curselection()];
			Tkx::clipboard_clear();
			Tkx::clipboard_append($selected);
		},
	);
	
	$lbox->g_pack();
	$copy_button->g_pack();
}	
