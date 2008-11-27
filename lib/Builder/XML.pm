package Builder::XML;
use strict;
use warnings;
use Carp;
use Builder::Utils;
use Builder::XML::Utils;
our $VERSION = '0.01';
our $AUTOLOAD;


sub __new__ {
    my ( $class ) = shift;
    my %args = Builder::XML::Utils::get_args( @_ );
    
    bless { 
        %args,
        block_id => $args{ _block_id }, 
        stack    => $args{ _stack },
        context  => Builder::XML::Utils::build_context(),
    }, $class;
}

sub AUTOLOAD {
    my ( $self ) = shift;
    my @args = @_;

    if ( $AUTOLOAD =~ /.*::(.*)/ ) {
        my $elt = $1;
        my $attr = undef;
        
        # sub args get resent as callback
        if ( wantarray ) {
             return sub { $self->$elt( @args ) };
        }
        
        # if first arg is hasharray then its attributes!
        $attr = shift @args  if ref $args[0] eq 'HASH';
        
        if ( ref $args[0] eq 'CODE' ) { 
            $self->__element__( context => 'start', element => $elt, attr => $attr );
            for my $inner ( @args ) {
                if ( ref $inner eq 'CODE' ) { $inner->() }
                else { $self->__push__( sub { $inner } ) }
            }
            $self->__element__( context => 'end', element => $elt );
            return;
        }
        
        # bog standard element         
        $self->__element__( element => $elt, attr => $attr, text => "@args" );
    }
    
    $self;
}

# TODO: look at XML::Element as alternative to my context method
#       Hmmm... XML::Element (& HTML::Element) doesnt have namespaces!?  ;-(

# TODO: So forget above!!  But do look at...
#  1. building subs (for speed).   Lets do benchmarking before attempting this!
#  2. XML::Entities    (option to decode on reading data & to encode on way out)
#  3. cdata - DONE
#  4. Direct print option - Added to Builder.pm.. appears to work.. need to write test
#  5. AUTOLOAD & DESTROY tags - solution?


######################################################
# methods

# Todo: amend below to only work on local stack (block_id) - NB. makes it different to Builder->render then?  Already Done?!
sub __render__ {
    my $self = shift;
    my $render;
    
    # render subs just for this block
    my @this_block = Builder::Utils::yank { $_->[0] == $self->{block_id} } @{ $self->{stack} };    
    while ( my $block = shift @this_block ) {
        my ( $block_id, $code ) = @$block;
        $render.= $code->();
    }
    return $render;
}

sub __element__ {
    my ( $self, %param ) = @_;
    $param{ text    } ||= '';
    $param{ context } ||= 'element';
    $self->{ context }->{ $param{ context } }->( $self, \%param );
    return;
}

sub __cdata__ {
    my $self = shift;
    return $_[0]  if $self->{ cdata } == 1;
    return $self->__cdatax__( $_[0] );
}

sub __cdatax__ {
    my $self = shift;
    return q{<!CDATA[[} . $_[0] . q{]]>};
}

sub __say__ {
    my ( $self, @say ) = @_;
    for my $said ( @say ) { $self->__push__( sub { $said } ) }
    return;
}

sub __push__ {
    my ( $self, $code ) = @_;
    
    # straight to output stream if provided
    if ( $self->{ _output } ) {
        print { $self->{ _output } } $code->();
        return;
    }
    
    # else add to stack
    push @{ $self->{ stack } }, [ $self->{ block_id }, $code ];
}

sub __inc__ { $_[0]->{ _inc }->() }

sub __dec__ { $_[0]->{ _dec }->() }

sub __level__ { $_[0]->{ _level }->() }

sub __tab__ {
    my $self = shift;
    return q{ } x ( $self->{ indent } * $self->__level__ )  if $self->{ indent };
    return q{};
}



sub DESTROY {
    my $self = shift;
    $self = undef;
}


1;


__END__

=head1 NAME

Builder::XML - Building block for XML

=head1 VERSION

Version 0.01

=cut



=head1 SYNOPSIS

TBD


=head1 EXPORT

None.


=head1 METHODS

=head2 AUTOLOAD

=head2 DESTORY


=head1 AUTHOR

Barry Walsh C<< <draegtun at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-builder at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Builder>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Builder::XML


You can also look for information at: L<Builder>

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


=head1 COPYRIGHT & LICENSE

Copyright 2008 Barry Walsh (Draegtun Systems Ltd), all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

