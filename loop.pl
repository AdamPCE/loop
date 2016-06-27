#!/usr/bin/perl -w

use strict;

my $appname = "loop";
my $ucfirstappname = ucfirst($appname);
my $version = "0.2.1";

# Different runlevels/runmodes
#my $runmode = 0;          # silent
my $runmode = 1;           # normal
#my $runmode = 2;           # verbose
#my $runmode = 3;          # debug

my $minimumarguments = 2;

&CheckCommandLineArguments;
PrintToScreen (2, "$ucfirstappname version $version started\n");
&PrintStartingInfo;

my $logfilepath = "/var/log";
my ($command, $interval) = @ARGV;

# Logfile
my $time = (&DetermineTime);
my $logfilenametime = $time;
$logfilenametime =~ s/\W//gi;

my $commanddesc = $command;
$commanddesc =~ /(\w*)\s/gi;
my $commandlogfilename = $1;

my $logfilename = $logfilenametime . "_" . $commandlogfilename;
PrintToScreen (3, "$time: $appname version $version started with logfile: $logfilepath/loop/$logfilename\n");

open (LOOPLOG, '>>', "$logfilepath/loop/$logfilename") or Error("Warning: Can't open logfile: $logfilepath/loop/$logfilename", 1);
PrintToScreen (2, "$time: $appname $version started with \"$command\" and an interval of $interval seconds\n");

print LOOPLOG "$time: $appname $version started with $command and interval: $interval!\n";

my $count = 0;
START:
$count++;
$time = (&DetermineTime);
print LOOPLOG "$time: $count instance: $command\n";

# do your thing!
print "$time: ";
system($command);
print "Sleeping $interval seconds...\n";
sleep $interval;
goto START;
exit;

#### Standard subroutines ####

sub PrintToScreen
{
     my ($msgtype, $msg) = (@_);
     if ($msgtype <= $runmode)
     {
          print "$msg";
     }
}

sub Error
{
     PrintToScreen(3, "We arrived at subroutine: Error!\n");
     my ($err_msg, $halt) = (@_);
     print "$err_msg\n";
     if ($halt == 1)
     {
          exit(1);
     }
}

sub DetermineTime
{
     PrintToScreen(3, "We arrived at subroutine: DetermineTime!\n");
     my ($second, $minute, $hour, $dayofmonth, $month, $year, $weekday, $dayofyear, $isdst) = localtime(time);
     my $realmonth = $month + 1;
     my $realyear = $year + 1900;
     my $timestamp = $realyear . "-" . &MakeTwoPosForTime($realmonth) . "-". &MakeTwoPosForTime($dayofmonth) . " "  .  &MakeTwoPosForTime($hour) . ":" . &MakeTwoPosForTime($minute) . ":" . &MakeTwoPosForTime($second);
     return ($timestamp);
}

sub MakeTwoPosForTime
{
     my $timestamppart = shift(@_);
     my $twopostimestamppart = sprintf("%0.2i", $timestamppart);
     return ($twopostimestamppart);
}

sub CheckCommandLineArguments
{
     my @options;
     my $elementcount = -1;
     my @undefarray;
     my @arguments = @ARGV;
     foreach my $element (@ARGV)
     {
          $elementcount++;
          if ($element =~ /^\-/)
          {
               if (($element eq "-s") || ($element eq "--silent")) { $runmode = 0; push (@undefarray, $elementcount) }
               elsif (($element eq "-n") || ($element eq "--normal")) { $runmode = 1; push (@undefarray, $elementcount) }
               elsif (($element eq "-v") || ($element eq "--verbose")) { $runmode = 2; push (@undefarray, $elementcount) }
               elsif (($element eq "-d") || ($element eq "--debug")) { $runmode = 3; push (@undefarray, $elementcount) }
               elsif (($element eq "-h") || ($element eq "--help")) { &PrintHelp; exit(1); }
          }
     }
     # Remove options from commandlinearguments
     foreach my $undefelement (@undefarray)
     {
          PrintToScreen (3,"Delete element: $undefelement\n");
          splice(@arguments, $undefelement, 1);
     }

     my $args = scalar(@arguments);
     #print "SCALAR ARGUMENTS: $args\n";
     if (scalar(@arguments) < $minimumarguments)
     {
          &Error("Lack of arguments!\n", 0);
          &PrintHelp;
          exit(1);
     }
     @ARGV = @arguments;
}

sub PrintStartingInfo
{
     if ($runmode == 3)
     {
          print "$ucfirstappname version $version invoked with $0 ";
          foreach my $cmdlinearg (@ARGV)
          {
               print $cmdlinearg, " ";
          }
          print "\n";
     }
}

sub PrintHelp
{
print <<HELPTEKST
$ucfirstappname version $version
Usage  : \$ $appname [-snvdh] "command" interval_in_seconds
Example: \$ $appname -v "echo hello" 60

Options:
-h           --help          Print this help
-v          --verbose     Run in verbose mode
-n          --normal     Default run-mode
-d          --debug          Run in debug-mode (for people who love reading)
HELPTEKST
}
