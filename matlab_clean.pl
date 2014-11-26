#!/usr/bin/perl -w

# This script:
#  - Runs matlab with all input arguments passed through
#  - Captures the output from stdout and stderr and the return value of the matlab process
#  - Filters the output to remove the non-standard characters
#  - Prints the output, and exits with the return value of matlab
# This appears to be a necessary evil to get clean matlab output to ctest:
#  http://www.mail-archive.com/cmake@cmake.org/msg02175.html

#use lib "./Text-Unidecode-0.04/lib";
#use Text::Unidecode;

my $osname = $^O;

my $cmd = 'matlab';
if ($osname eq "cygwin" || $osname eq "MSWin32") {
  use File::Basename;
  my $dirname = dirname(__FILE__);
  chomp($cmd = `cmake $dirname/../pod-build -N -L | grep matlab | cut -d "=" -f2 | cygpath -u -f -`);
  print "$cmd\n";  # matlab on windows doesn't show the version at startup.
  $cmd = "\"$cmd\"";
}

foreach my $a(@ARGV) {
  $cmd .= " \"$a\"";
}

if ($osname eq "cygwin" || $osname eq "MSWin32") {
  $tmpfile = "c:\\tmp\\" . time() . "_" . int(rand(100000));
  $cmd .= " -wait -nosplash -nodesktop -logfile \"$tmpfile\"";
} else {
  $tmpfile = "/tmp/" . time() . "_" . int(rand(100000));
  $cmd .= " -nosplash -nodisplay -logfile \"$tmpfile\"";
}
$cmd .= " &> /dev/null";

#print($cmd);

my $retval = system($cmd) >> 8;

# read entire file in (using a trick from http://www.perlmonks.org/?node_id=1952)
local $/=undef;
open FILE, "$tmpfile" or die "Couldn't open file: $!";
$matlab_output = <FILE>;
close FILE;

# rm the temp file
unlink $tmpfile;

print($matlab_output);
exit($retval);
