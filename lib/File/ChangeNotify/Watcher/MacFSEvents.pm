package File::ChangeNotify::Watcher::MacFSEvents;

use strict;
use 5.008_001;
our $VERSION = '0.01';

use Moose;
extends 'File::ChangeNotify::Watcher';

use IO::Select;
use Mac::FSEvents;

has _fsevents => (
    is => 'ro',
    isa => 'Mac::FSEvents',
    lazy_build => 1,
);

has _sel => (
    is  => 'rw',
    isa => 'IO::Select',
);

sub _build__fsevents {
    my $self = shift;

    # TODO support multi directories
    my $fs = Mac::FSEvents->new({ path => $self->directories->[0] });
    $self->_sel( IO::Select->new($fs->watch) );

    return $fs;
}

sub sees_all_events { 1 }

sub wait_for_events {
    my $self = shift;

    # TODO support $self->filter

    my @ev = $self->_fsevents->read_events; # blocking
    return map $self->_transform_event($_), @ev;
}

sub _interesting_events {
    my $self = shift;

    # TODO support $self->filter

    $self->_fsevents; # lazy build

    if ($self->_sel->can_read(0)) { # non-blocking
        my @ev = $self->_fsevents->read_events;
        return map $self->_transform_event($_), @ev;
    }

    return;
}

sub _transform_event {
    my($self, $ev) = @_;

    $self->event_class->new(
        path => $ev->path, # TODO: is a directory not a file path
        type => 'unknown',
    );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=encoding utf-8

=for stopwords

=head1 NAME

File::ChangeNotify::Watcher::MacFSEvents - Bridges Mac::FSEvents to File::ChangeNotify

=head1 SYNOPSIS

  # This automatically loads MacFSEvents driver if installed
  use File::ChangeNotify;

  my $watcher = File::ChangeNotify->instantiate_watcher(
      directories => [ '/my/path' ], # Only single directly is supported
      # filter is not supported
  );

  for my $event ($watcher->new_events) {
      warn $event->path; # returns the directory, not file
      warn $event->type; # always 'unknown'
  }

=head1 DESCRIPTION

File::ChangeNotify::Watcher::MacFSEvents is a File::ChangeNotify
watcher backend that uses Mac OS X FSEvents API (since 10.5 Leopard)
thanks to Mac::FSEvents.

Because of fsevents API limitation, this driver only implements
watching a single directory, and can't filter events based on file
path (because the API doesn't return the path name).

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<File::ChangeNotify> L<Mac::FSEvents>

=cut
