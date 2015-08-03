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
use POSIX ":sys_wait_h";

my $osname = $^O;

my $cmd = 'matlab';
if ($osname eq "cygwin" || $osname eq "MSWin32") {
  use sigtrap qw/handler signal_handler normal-signals/;

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

# create the tmp file (in case the child gets there first)
open FILE, ">$tmpfile";
print FILE "";
close FILE;

if ($child_pid = fork()) { # parent process
  # this is a perl version of doing:  system("tail -f $tmpfile");
  # http://docstore.mik.ua/orelly/perl4/cook/ch08_06.htm
  open FILE, "$tmpfile" or die "Couldn't open file: $!";
  my $segfault = 0;
  for (;;) {
    while (<FILE>) {
      print;
      if (/Segmentation violation|malloc_error_break/) {
        $segfault = 1;
      }
    }
    if ($segfault) { exit(1); }
    sleep 1;
    if (waitpid($child_pid,WNOHANG) != 0) {
      # then the child is done: http://perlmaven.com/how-to-check-if-a-child-process-is-still-running
      while (<FILE>) { print; } # output the rest

      my $child_retval = $? >> 8;
      unlink $tmpfile;   # rm the temp file
      if ($child_retval != 0) {
	  print "matlab exit code: $child_retval\n";
      }
      exit($child_retval);
    }

    seek(FILE, 0, 1);
  }
} else { # child process
  my $retval = system($cmd) >> 8;
  exit($retval);
}




sub signal_handler {
  # from http://stackoverflow.com/questions/4717118/what-happens-to-a-sigint-c-when-sent-to-a-perl-script-containing-children
    local $SIG{HUP} = "IGNORE";
    kill HUP => -$$;   # the killpg(getpid(), SIGHUP) syscall
    die "Caught a signal $!";
}
