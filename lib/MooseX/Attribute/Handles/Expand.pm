package MooseX::Attribute::Handles::Expand;
# ABSTRACT: Expands '*' in handle functions with the attribute name

=head1 SYNOPSIS

    package Foo;
    use Moose;
    use MooseX::Attribute::Handles::Expand;

    has [ qw/ bar baz / ] => (
        traits => [ 'Array' ],
        default => sub { [] },
        handles => {
            'size_*' => 'count',
        },
    );


    my $foo = Foo->new;
    ...;
    print $foo->size_bar;
    print $foo->size_baz;

=head1 DESCRIPTION

Grooms the name of delegated methods in the handles and expands all
instances of C<*> into the attribute name.

=cut

use strict;
use warnings;

use Moose::Role;

use List::Util qw/ pairmap /;

my %switcharoo;

before 'install_delegation' => sub {
    my( $self ) = @_;

    my $name = $self->name;
    my $handles = $self->handles;

    for my $key ( grep { /\*/ } keys %$handles ) {
        ( my $new_key = $key ) =~ s/\*/$name/g;
        $switcharoo{$new_key} = $key;
        $handles->{$new_key} = delete $handles->{$key}
    }

};

# reset the names to the '*-y ones
after install_delegation => sub {
    my( $self ) = @_;

    my $name = $self->name;
    my $handles = $self->handles;

    while( my ($k,$v) = each %switcharoo ) {
        $handles->{$v} = delete $handles->{$k};
    }

    %switcharoo = ();
};

{
    package Moose::Meta::Attribute::Custom::Trait::Handles::Expand;

    sub register_implementation { 'MooseX::Attribute::Handles::Expand' }

}

1;


1;
