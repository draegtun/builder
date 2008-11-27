package Builder;
use strict;
use warnings;
use Carp;
our $VERSION = '0.01';


sub new {
    my ( $class, %args ) = @_;
    my $level = 0;
    bless { 
        %args, 
        blocks => [], 
        stack  => [], 
        level  => sub { $level },
        inc    => sub { $level++ },
        dec    => sub { $level-- },
    }, $class;
}

sub block {
    my ( $self, $block, %args ) = @_;
    eval "require $block";
    return $self->_new_block( $block->__new__( 
        %args, 
        _output   => $self->{output},
        _inc      => $self->{inc},
        _dec      => $self->{dec},
        _level    => $self->{level},
        _block_id => $self->_block_id, 
        _stack    => $self->{ stack } 
    ));
}

sub render {
    my ( $self ) = @_;
    my $render;
    
    # loop thru return chain (DOM!)
    while ( my $block = shift @{ $self->{ stack } } ) {
        my ( $block_id, $code ) = @$block;
        $render.= $code->();
    }
    
    return $render;
}

sub flush {
    my ( $self ) = @_;
    $self->{ stack } = [];
}

sub _block_id {
    my ( $self ) = shift;
    return scalar @{ $self->{blocks} };
}

sub _new_block {
    my ( $self, $block ) = @_;
    push @{ $self->{blocks} }, $block;
    return $block;
}


1;

__END__



=head1 NAME

Builder - Build XML, HTML, CSS and other outputs in blocks

=head1 VERSION

Version 0.01



=head1 SYNOPSIS

Example using just one building block (for now!)....

    use Builder;


    my $builder = Builder->new();
    
    my $xm = $builder->block( 'Builder::XML' );


    $xm->body(
        $xm->div( { id => 'mydiv' }, 
            $xm->bold( 'hello' ), 
            $xm->em( 'world' ) 
        );
    );


    say $builder->render;


    # will produce =>
    # <body><div id="mydiv"><bold>hello</bold><em>world</em></div></body>



=head1 DESCRIPTION

TBD... add multiple blocks & sub (coderef) examples.

TBD... add Builder non-OO example (once back in codebase!)


=head1 EXPORT

Nothing (at this moment!)


=head1 METHODS

=head2 new

Constructor.  Currently no args are used.

    my $builder = Builder->new();


=head2 block

Create a block.  First arg is the block to use, for eg.  'Builder::XML'.  Second arg is a hashref (or it will be!)

    my $builder = Builder->new();

    my $xm = $builder->block( 'Builder::XML', cdata => 1 );       # v 0.01

    my $xm = $builder->block( 'Builder::XML', { cdata => 1 } );   # v 0.02 onwards


For options that can be passed as args please see relevant builder documentation.


=head2 render

Renders all the blocks for the requested builder stack returning the information.

    my $output = $builder->render;

=head2 flush

The render method will automatically flush the builder stack.   Unlikely this will be any use externally!

    $builder->flush;     # there goes all the blocks just built ;-(


=head1 AUTHOR

Barry Walsh C<< <draegtun at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-builder at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Builder>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Builder


You can also look for information at:  http://github.com/draegtun/builder

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Builder>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Builder>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Builder>

=item * Search CPAN

L<http://search.cpan.org/dist/Builder/>

=back


=head1 ACKNOWLEDGEMENTS

=over 4

My main inspiration came primarily from Builder for Ruby L<http://builder.rubyforge.org/>
 and also a little bit from Groovy Builders L<http://groovy.codehaus.org/Builders>

=back


=head1 SEE ALSO

=over 4

=item B<Other Builder::* modules>:

L<Builder::XML>

=item B<Similar CPAN modules>:

L<Class::XML>, L<XML::Generator>

=back

=head2 Builder Source Code

Can be (shortly!) found on GitHub at  http://github.com/draegtun/builder/tree/master

=head1 DISCLAIMER

This is (near) beta software.   I'll strive to make it better each and every day!

However I accept no liability I<whatsoever> should this software do what you expected ;-)



=head1 COPYRIGHT & LICENSE

Copyright 2008 Barry Walsh (Draegtun Systems Ltd), all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.



