use Time::Local;

my $arg=shift;
my $epochseconds = 0;
my $epochmicroseconds = 0;
if ($arg =~ /^\[(.+)\] .+is ready to run a smarter planet/) {
	my $timestamp = $1;
	if ($timestamp =~ /(\d+)\/(\d+)\/(\d+)(,|) (\d+):(\d+):(\d+):(\d+) (.+)/) {
		$epochseconds =  timelocal($7,$6,$5,$2,$1-1,$3+2000);
		$epochmicroseconds = $8;
		print("$epochseconds.$epochmicroseconds");
	} else {
	        print "Timestamp $timestamp is not in recognized format\n";
	        exit;
        }
}
