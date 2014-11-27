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
  use Cwd 'abs_path';
  use Cwd;
  my $dirname = dirname(abs_path(__FILE__));
  $startdir = cwd();
  chdir("$dirname/../pod-build");  # use perl cd instead of cmake dir because dirname is in cygwin format (instead of win style)
  $cmd = `cmake -N -L`;
  chdir($startdir);
  my @lines = split(/\n/,$cmd);
  @lines = grep(/winmat/,@lines);
  if (!@lines) {
      print "Warning: Couldn't find matlab windows exe from cmake cache\n";
      $cmd = 'matlab -wait';
  } else {
      $cmd = (split(/=/,$lines[0]))[1];
      #  chomp($cmd = `cmake $dirname/../pod-build -N -L | grep winmat | cut -d "=" -f2 | cygpath -u -f -`);
      print "$cmd\n";  # matlab on windows doesn't show the version at startup.
      $cmd = '"' . substr($cmd,0,length($cmd)-1) . '"';  # for some reason had to zap special character at the end (chomp wasn't getting it)
  }
}

foreach my $a(@ARGV) {
  $cmd .= " \"$a\"";
}


if ($osname eq "cygwin" || $osname eq "MSWin32") {
  $tmpfile = "c:\\tmp\\" . time() . "_" . int(rand(100000));
  $cmd .= " -nosplash -nodesktop -logfile \"$tmpfile\"";
} else {
  $tmpfile = "/tmp/" . time() . "_" . int(rand(100000));
  $cmd .= " -nosplash -nodisplay -logfile \"$tmpfile\"";
}
$cmd .= " > /dev/null 2>&1";

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
