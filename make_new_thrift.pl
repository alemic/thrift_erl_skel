#!/usr/bin/perl

use FindBin;

sub first_service {
  my ($thrift_file) = @_;
  my $service = undef;
  open SERVICE, "< $thrift_file";
  while (my $line = <SERVICE>)
    {
      if ($line =~ m#service\s+([\w\.]+)#)
        {
          $service_name = $1;
          last;
        }
     }
  close SERVICE;
  return $service_name;
}

my $SKEL_DIR="$FindBin::Bin/thrift_skel";
my $SKEL_SUB_SHORTNAME = 'SKEL_SHORTNAME';
my $SKEL_SUB_ERLANGIFIED_LONGNAME = 'SKEL_ERLANGIFIED_LONGNAME';

die "usage: $0 short_name thrift_file port" unless @ARGV == 3;

my ($SHORT_NAME, $THRIFT_FILE, $SERVICE_PORT) = @ARGV;

my $ERLANG_SERVICE = lcfirst &first_service($THRIFT_FILE);

&do("cp -r $SKEL_DIR $SHORT_NAME");
&do("thrift -r --gen erl $THRIFT_FILE");
&do("mv gen-erl/*.erl $SHORT_NAME/src");
&do("mkdir -p $SHORT_NAME/include");
&do("mv gen-erl/*.hrl $SHORT_NAME/include");
&do("rmdir gen-erl");

&do("perl -p -i -e 's/$SKEL_SUB_SHORTNAME/$SHORT_NAME/g;' `find $SHORT_NAME -type f`");
&do("perl -p -i -e 's/$SKEL_SUB_ERLANGIFIED_LONGNAME/$ERLANG_SERVICE/g;' `find $SHORT_NAME -type f`");
&do("perl -p -i -e 's/SKEL_PORT/$SERVICE_PORT/g;' `find $SHORT_NAME -type f`");

# Rename
my $files_string = `find $SHORT_NAME -type f -print0`;
my @files = split /\0/, $files_string;

foreach my $file (@files) {
  my $newfile = $file;
  $newfile =~ s/thrift_skel/$SHORT_NAME/;
  print "$file -> $newfile\n";
  rename($file, $newfile);
}

sub do {
  my $todo = shift;
  print "$todo\n";
  system($todo);
}
