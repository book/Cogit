package Git::PurePerl::Object::Tag;
use Moose;
use MooseX::StrictConstructor;
use Moose::Util::TypeConstraints;
use namespace::autoclean;

extends 'Git::PurePerl::Object';

has '+kind' => ( default => 'tag' );

has object => (
    is => 'rw',
    isa => 'Str',
);

has tag => (
    is => 'rw',
    isa => 'Str',
);

has tagger => (
    is => 'rw',
    isa => 'Git::PurePerl::Actor',
);

has tagged_time => (
    is => 'rw',
    isa => 'DateTime',
);

has comment => (
    is => 'rw',
    isa => 'Str',
);

has object_kind => (
    is => 'rw',
    isa => 'ObjectKind',
);

my %method_map = (type => 'object_kind');

sub BUILD {
    my $self = shift;
    my @lines = split "\n", $self->content;
    while ( my $line = shift @lines ) {
        last unless $line;
        my ( $key, $value ) = split ' ', $line, 2;

        if ($key eq 'tagger') {
            my @data = split ' ', $value;
            my ($email, $epoch, $tz) = splice(@data, -3);
            my $name = join(' ', @data);
            my $actor =
                Git::PurePerl::Actor->new( name => $name, email => $email );
            $self->tagger($actor);
            my $dt= DateTime->from_epoch( epoch => $epoch, time_zone => $tz );
            $self->tagged_time($dt);
        } else {
            my $method = $method_map{$key} || $key;
            $self->$method($value);
        }
    }
    $self->comment( join "\n", @lines );
}

__PACKAGE__->meta->make_immutable;

