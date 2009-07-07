use strict;
use Test::More tests => 3;
use File::ChangeNotify;

my $watcher = File::ChangeNotify->instantiate_watcher(directories => [ 't' ]);
isa_ok $watcher, 'File::ChangeNotify::Watcher::MacFSEvents';

{
    my @events = $watcher->new_events;
    is $#events, -1;
}

{
    open my $out, ">t/testdata";
    print $out time;
}

diag "sleep 3";
sleep 3;

my @events = $watcher->new_events;

{
    is $#events, 0;
}

unlink "t/testdata";

