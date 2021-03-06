package Data::Stream::Bulk::DBI;
# ABSTRACT: N-at-a-time iteration of L<DBI> statement results.

use Moose;

use namespace::clean -except => 'meta';

with qw(Data::Stream::Bulk::DoneFlag) => { -excludes => [qw/is_done all finished/] };

has sth => (
    isa => "Object",
    is  => "ro",
    required => 1,
    handles => [qw(fetchall_arrayref)],
    clearer => "finished",
);

has slice => (
    is  => "ro",
);

has max_rows => (
    isa => "Int",
    is  => "rw",
    default => 500,
);

sub get_more {
    my $self = shift;
    $self->fetchall_arrayref( $self->slice, $self->max_rows );
}

sub all {
    my $self = shift;

    my $all = $self->fetchall_arrayref( $self->slice );

    $self->_set_done;

    return @$all;
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__;

=pod

=head1 SYNOPSIS

    use Data::Stream::Bulk::DBI;

    my $sth = $dbh->prepare("SELECT hate FROM sql"); # very big resultset
    $sth->execute;

    return Data::Stream::Bulk::DBI->new(
        sth => $sth,
        max_rows => $n, # how many at a time
        slice => [ ... ], # if you want to pass the first param to fetchall_arrayref
    );

=head1 DESCRIPTION

This implementation of L<Data::Stream::Bulk> api works with DBI statement
handles, using L<DBI/fetchall_arrayref>.

It fetches C<max_rows> at a time (defaults to 500).

=attr sth

The statement handle to call C<fetchall_arrayref> on.

=attr slice

Passed verbatim as the first param to C<fetchall_arrayref>. Should usually be
C<undef>, provided for completetness.

=attr max_rows

The second param to C<fetchall_arrayref>. Controls the size of each buffer.

Defaults to 500.

=method get_more

See L<Data::Stream::Bulk::DoneFlag>.

Calls C<fetchall_arrayref> to get the next chunk of rows.

=method all

Calls C<fetchall_arrayref> to get the raminder of the data (without specifying
C<max_rows>).

=cut

