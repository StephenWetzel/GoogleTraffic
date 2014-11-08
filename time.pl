#!/usr/bin/perl
# by Stephen Wetzel Nov 06 2014
#Requires cURL is installed

use strict;
use warnings;

my $start = "39.985456,-74.889448"; #rt 38
my $end   = "39.876950,-75.005517"; #295 exit

my %locations = (
	'38'   => "39.985456,-74.889448",
	'561'  => "39.876950,-75.005517"
	);

if ($#ARGV >= 1)
{#grab the start and endpoint from command line
	$start = $locations{$ARGV[0]};
	$end   = $locations{$ARGV[1]};
}

my $sleepTime = 60;
my $secToRun = 10; #this is on what second the script should run, used to keep it on time
my $baseTime = 10; #probably could grab this from no traffic time

use POSIX qw(strftime);
my $formattedTime = strftime "%F;%a;%H:%M:%S", localtime;
my $timestamp = time;

#use autodie; #die on file not found
$|++; #autoflush disk buffer

my $url = "https://maps.google.com/maps?saddr=$start&daddr=$end&output=js";
print "\nURL:\n$url";
my $body=''; #response body

while (1 != 2)
{
	$formattedTime = strftime "%F;%a;%H:%M:%S", localtime; 
	$timestamp = time;
	$body = `curl '$url' 2>/dev/null`; #get response body from curl
	my $time=0;
	
	#In current traffic: 11 mins 
	if ($body =~ m/In current traffic: (\d+) min/)
	{#just mins
		$time = $1;
	}
	elsif ($body =~ m/In current traffic: (\d+) hour(s)? (\d+) min/)
	{#hours and mins
		$time = $1 * 60 + $3;
	}
	
	open my $ofile, '>>', 'trafficTimes.csv';
	
	print "\n$timestamp; $formattedTime; $time  ";
	print "*" x ($time - $baseTime); #the fancy bar graph
	print $ofile "\n$timestamp;$formattedTime;$time";
	close $ofile;
	
	my $secs = strftime "%S", localtime; #get current seconds so we can always run on same seconds
	sleep($sleepTime-$secs+$secToRun);
}

print "\nDone\n\n";
