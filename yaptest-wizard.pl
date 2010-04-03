#!/usr/bin/env perl 
use strict;
use warnings;
use yaptest;
use File::Basename;

$| = 1;

print "                    __  __            __            __                 \n";
print "                    \\ \\/ /___ _____  / /____  _____/ /_                \n";
print "                     \\  / __ `/ __ \\/ __/ _ \\/ ___/ __/                \n";
print "                     / / /_/ / /_/ / /_/  __(__  ) /_                  \n";
print "                    /_/\\__,_/ .___/\\__/\\___/____/\\__/                  \n";
print "                           /_/                                         \n";
print "                Doing the tedious bits so you don't have to            \n";
print "                                                                       \n";  
print "    THIS WIZARD CURRENLTY ONLY DEALS WITH THE CREATION OF NEW DATABASES\n";
print "                               AND TEST AREAS\n";

my $global_dbname;
my $global_testarea;

# Ignore config files that don't exist
if (defined($ENV{'YAPTEST_CONFIG_FILE'}) and ! -e $ENV{'YAPTEST_CONFIG_FILE'}) {
	print "WARNING: Ignoring non-existant config file: " . $ENV{'YAPTEST_CONFIG_FILE'} . "\n";
	delete $ENV{'YAPTEST_CONFIG_FILE'};
}

# Ask user to create a database if one isn't currenlty configured.
unless (defined($ENV{'YAPTEST_CONFIG_FILE'})) {
	db_unconfigured();
}

# Present options if a db is configured
my $config_file = $ENV{'YAPTEST_CONFIG_FILE'};
my $y = yaptest->new;
while (1) {
	db_configured($y);
}

sub db_unconfigured {
	print "=========================================================================\n";
	print "Database Configuration\n";
        print "\n";
        print "You are currenlty not configured to use a database.\n";
        print "\n";
        print "Options:\n";
        print "  1: Create a new database\n";
        print "  q: Quit\n";
        print "\n";
        print "NB: If you previously created a database and want to use it,\n";
        print "    quit, change to the corresponding directory, \n";
        print "    'source env.sh', then re-run this wizard.\n";
	print "\n";
	my $option = get_option(undef, "1", "q");
	print "-------------------------------------------------------------------------\n";

	if ($option eq "1") {
		create_new_db();
	} elsif ($option eq "q") {
		exit 0;
	} else {
		print "INTERNAL ERROR: This isn't supposed to happen\n";
	}
}

sub db_configured {
	my $y = shift;
	my $dbname = $global_dbname = $y->get_config('yaptest_dbname');
	my $test_area = $global_testarea = $y->get_config('yaptest_test_area');
	my @test_areas = @{$y->get_test_areas()};
	print "=========================================================================\n";
        print "Database Configuration\n";
        print "\n";
        print "You are currently configured to use:\n";
        print "  Database:    $dbname\n";
        print "  Test Dir:    " . dirname($config_file) . "\n";
        print "\n";
	print "The following test areas exist in this database:\n";
	if (scalar(@test_areas)) {
		foreach my $t_href (@test_areas) {
			print "  ". $t_href->{name};
			print "\n";
		}
	} else {
		print "  <none>\n";
	}
	print "\n";
        print "Options:\n";
        print "  1: Create a new test area in above database\n";
        print "  2: Create a new database\n";
        print "  q: Quit\n";
        print "\n";
        print "NB: If you previously created different database and want \n";
        print "    to use it, quit, change to the corresponding directory,\n";
        print "    'source env.sh', then re-run this wizard.\n";
        print "\n";
	my $option = get_option(undef, qw(1 2 q));
	print "-------------------------------------------------------------------------\n";

	if ($option eq "1") {
		create_new_test_area($y);
	} elsif ($option eq "2") {
		create_new_db();
	} elsif ($option eq "q") {
		exit 0;
	} else {
		print "INTERNAL ERROR: This isn't supposed to happen\n";
	}
}

sub test_area_config {
	my $y = shift;
	my $dbname = $y->get_config('yaptest_dbname');
	my $test_area = $y->get_config('yaptest_test_area');
	my @test_areas = $y->get_test_areas();
	print "=========================================================================\n";
	print "Test Area Configuration\n";
	print "\n";
	print "You are currently configured to use:\n";
	print "  Test Area:   " . (defined($test_area) ? $test_area : "<none>") . "\n";
	print "  Database:    $dbname\n";
        print "  Test Dir:    " . dirname($config_file) . "\n";
	print "\n";
	print "The following test areas exist in this database:\n";
	if (scalar(@test_areas)) {
		print "  <none>\n";
	} else {
		foreach my $t (@test_areas) {
			print "  $t";
			if ($t eq $test_area) {
				print " (current)\n";
			} 
			print "\n";
		}
	}
	print "\n";
	print "Options:\n";
	print "  1: Create a new test area\n";
	print "  b: Back\n";
	print "  q: Quit\n";
	my $option = get_option(undef, qw(1 b q));
	print "-------------------------------------------------------------------------\n";

	if ($option eq "1") {
		create_new_test_area($y);
	} elsif ($option eq "b") {
		return;
	} elsif ($option eq "q") {
		exit 0;
	} else {
		print "INTERNAL ERROR: This isn't supposed to happen\n";
	}
}

sub get_option {
	my ($prompt, @options) = @_;
	my $invalid_option = 1;
	my $option;

	while ($invalid_option) {
		if (defined($prompt)) {
			print "$prompt: ";
		} else {
			print "Enter option (" . join (", ", @options) . "): ";
		}

		$option = <>;
		chomp $option;

		if (grep { $option eq $_ } @options) {
			$invalid_option = 0;
		} else {
			print "ERROR: Invalid option\n";
		}
	}

	return $option;
}

sub create_new_test_area {
	my $y = shift;
	print "=========================================================================\n";
	print "Create New Test Area\n";
	print "\n";
	print "To create a new test area (internal, vlan100, network123, etc.) enter the\n";
	print "test area name below.  A directory of the name name will be created at\n";
	print "same time.\n";
	print "\n";
	my $current_dir = `pwd`; chomp $current_dir;
	print "Current Directory: $current_dir\n";
	print "Enter name for new test area (or CTRL-C to quit): ";
	my $test_area = <>;
	print "-------------------------------------------------------------------------\n";
	chomp $test_area;
	print "Database name: $test_area\n";

	print "Creating directory '$test_area'...";
	if (mkdir $test_area) {
		print "done\n";
	} else {
		print "ERROR: $!\n";
		exit 1;
	}
	chdir($test_area);

	print "Creating test area '$test_area'\n";
	$y->insert_test_area(name => $test_area, config_file => "yaptest.conf");
	$y->set_test_area($test_area);
	chdir("..");
	print "-------------------------------------------------------------------------\n";
}

sub create_new_db {
	print "=========================================================================\n";
	print "Create New Database\n";
	print "\n";
	print "Enter a name for the new database.  A subdirectory of the same name will\n";
	print "be created at the same time.\n";
	print "\n";
	my $current_dir = `pwd`; chomp $current_dir;
	print "Current Directory: $current_dir\n";
	print "Enter name for new yaptest database (or CTRL-C to quit): ";
	my $dbname = <>;
	print "-------------------------------------------------------------------------\n";
	chomp $dbname;
	print "Database name: $dbname\n";

	print "Creating directory '$dbname'...";
	if (mkdir $dbname) {
		print "done\n";
	} else {
		print "ERROR: $!\n";
		exit 1;
	}
	chdir($dbname);

	print "Creating database '$dbname'\n";
	my $y = yaptest->new($dbname, 'yaptest.conf');
	
	print "Restarting wizard with new configuration\n";
	exec(`cat env.sh;` . $0);
}

END {
	if (defined($global_dbname)) {
		print "IMPORTANT: To use your newly created test areas you must first:\n";
		print "           \$ cd " . $global_dbname . "/yourtestarea\n";
		print "           \$ source env.sh\n\n";

		print "You can then run the yaptest-*.pl scripts individually or just run\n";
		print "yaptest-db-ips.sh to run them all in the correct order.\n";
	} else {
		print "IMPORTANT: No database was created.  You need to do 1 of 3 things:\n";
		print "           - Create a database using this wizard,\n";
		print "           - Create a database yaptest-new-db.pl; or\n";
		print "           - Use an existing database: cd dbname; source env.sh\n";
	}
}

