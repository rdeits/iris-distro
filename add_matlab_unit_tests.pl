#!/usr/bin/perl -w

# Note: this must be run from the root directory of the pod, or the root must be passed in as the first argument
if ($#ARGV>-1) {
  print("changing directory to $ARGV[0]\n");
  chdir($ARGV[0]);
}

chomp($CMAKE_INSTALL_PREFIX = `cmake pod-build -L | grep CMAKE_INSTALL_PREFIX | cut -d "=" -f2`);
chomp($CMAKE_SOURCE_DIR = `pwd`);
chomp($POD_NAME = `cmake pod-build -L | grep POD_NAME | cut -d "=" -f2`);

if ($^O eq 'cygwin') {
  chomp($CMAKE_INSTALL_PREFIX = `cygpath -w $CMAKE_INSTALL_PREFIX`);
  chomp($CMAKE_SOURCE_DIR = `cygpath -w $CMAKE_SOURCE_DIR`);
  $matlab_cmd = "matlab -wait -nodesktop -nosplash";
  chomp($perl_cmd = `which perl`);
  chomp($perl_cmd = `cygpath -w $perl_cmd`);
  $perl_cmd = "\"$perl_cmd\"";
} else {
  $matlab_cmd = "matlab -nodisplay -nosplash";
  $perl_cmd = "";
}

# write unit tests to pod-build/matlab_ctests
system("$matlab_cmd -r \"addpath('$CMAKE_INSTALL_PREFIX/matlab'); addpath_$POD_NAME; options.gui = false; options.autorun = false; options.test_list_file = 'pod-build/matlab_ctests'; unitTest(options); exit;\"");

open(my $in, 'pod-build/matlab_ctests');
open(my $ctestfile, '>>', 'pod-build/CTestTestfile.cmake');

while (<$in>) {
  ($test,$testdir,$props) = split(' ',$_,3);
  $testname = $testdir."/".$test;
  $testname =~ s/\Q$CMAKE_SOURCE_DIR\E[\/\\]//;
  $testname =~ s/\\/\//g;

#  $failcondition = "1";   # missing dependency => failure
  $failcondition = "~strncmp(ex.identifier,'Drake:MissingDependency',23)";  # missing dependency => pass

  print $ctestfile "ADD_TEST($testname $perl_cmd \"$CMAKE_SOURCE_DIR/cmake/matlab_clean.pl\" \"-r\" \"rng('shuffle'); rng_state=rng; disp(sprintf('To reproduce this test use rng(%d,''%s'')',rng_state.Seed,rng_state.Type)); disp(' '); addpath('$CMAKE_INSTALL_PREFIX/matlab'); addpath_$POD_NAME; global g_disable_visualizers; g_disable_visualizers=true; try, fevalPackageSafe('$test'); catch ex, disp(getReport(ex,'extended')); disp(' '); fprintf('<test_name>%s</test_name> <error_id>%s</error_id> <error_message>%s</error_message>','$testname',ex.identifier,ex.message); disp(' '); force_close_system; exit($failcondition); end; force_close_system; exit(0)\")\n";

  $props = "WORKING_DIRECTORY \"$testdir\" $props";
  print $ctestfile "SET_TESTS_PROPERTIES($testname PROPERTIES " . $props .")\n";
}
