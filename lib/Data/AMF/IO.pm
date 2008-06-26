package Data::AMF::IO;
use Moose;

use constant ENDIAN => unpack('S', pack('C2', 0, 1)) == 1 ? 'BIG' : 'LITTLE';

has data => (
    is      => 'rw',
    isa     => 'Str',
    default => sub { '' },
    lazy    => 1,
);

has pos => (
    is      => 'rw',
    isa     => 'Int',
    default => sub { 0 },
    lazy    => 1,
);

__PACKAGE__->meta->make_immutable;

sub read {
    my ($self, $len) = @_;

    my $data = substr $self->data, $self->pos, $len;
    $self->pos( $self->pos + $len );

    $data;
}

sub read_u8 {
    my $self = shift;

    my $data = $self->read(1);
    unpack('C', $data);
}

sub read_u16 {
    my $self = shift;

    my $data = $self->read(2);
    unpack('n', $data);
}

sub read_s16 {
    my $self = shift;

    my $data = $self->read(2);

    return unpack('s>', $data) if $] >= 5.009002;
    return unpack('s', $data)  if ENDIAN eq 'BIG';
    return unpack('s', swap($data));
}

sub read_u32 {
    my $self = shift;

    my $data = $self->read(4);
    unpack('N', $data);
}

sub read_double {
    my $self = shift;

    my $data = $self->read(8);
    return unpack('d>', $data) if $] >= 5.009002;
    return unpack('d', $data)  if ENDIAN eq 'BIG';
    return unpack('d', swap($data));
}

sub read_utf8 {
    my $self = shift;

    my $len = $self->read_u16;
    $self->read($len);
}

sub read_utf8_long {
    my $self = shift;

    my $len = $self->read_u32;
    $self->read($len);
}

sub swap {
    join '', reverse split '', $_[0];
}

sub write {
    my ($self, $data) = @_;
    $self->{data} .= $data;
}

sub write_u8 {
    my ($self, $data) = @_;
    $self->write( pack('C', $data) );
}

sub write_u16 {
    my ($self, $data) = @_;
    $self->write( pack('n', $data) );
}

sub write_s16 {
    my ($self, $data) = @_;

    $self->write( pack('s>', $data) ) if $] >= 5.009002;
    $self->write( pack('s', $data) )  if ENDIAN eq 'BIG';
    $self->write( swap pack('s', $data) );
}

sub write_u32 {
    my ($self, $data) = @_;
    $self->write( pack('N', $data) );
}

sub write_double {
    my ($self, $data) = @_;

    $self->write( pack('d>', $data) ) if $] >= 5.009002;
    $self->write( pack('d', $data) )  if ENDIAN eq 'BIG';
    $self->write( swap pack('d', $data) );
}

sub write_utf8 {
    my ($self, $data) = @_;

    my $len = bytes::length($data);

    $self->write_u16($len);
    $self->write($data);
}

sub write_utf8_long {
    my ($self, $data) = @_;

    my $len = bytes::length($data);

    $self->write_u32($len);
    $self->write($data);
}

1;

