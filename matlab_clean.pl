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

my $cmd = 'matlab';
#$cmd = "\"/cygdrive/c/Program Files/MATLAB/R2012a/bin/win32/MATLAB.exe\""; # hard code just for the moment  

foreach my $a(@ARGV) {
  $cmd .= " \"$a\"";
}

my $osname = $^O;

if ($osname eq "cygwin" || $osname eq "MSWin32") {
  $tmpfile = "c:\\tmp\\" . time() . "_" . int(rand(100000));
  $cmd .= " -wait -nosplash -nodesktop -logfile \"$tmpfile\"";    
} else {
  $tmpfile = "/tmp/" . time() . "_" . int(rand(100000));  
  $cmd .= " -nosplash -nodisplay";
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

