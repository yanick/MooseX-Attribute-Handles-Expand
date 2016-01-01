use strict;
use warnings;

use Test::More tests => 2;

{
    package Foo;
    use Moose;
    use MooseX::Attribute::Handles::Expand;

    my $i = 1;

    has [ qw/ bar baz / ] => (
        traits => [ 'Array', 'Handles::Expand' ],
        default => sub { [ (1) x $i++ ] },
        handles => {
            'size_*' => 'count',
        },
    );
}

my $foo = Foo->new;

is $foo->size_bar => 1;
is $foo->size_baz => 2;



