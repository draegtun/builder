package Builder::XML::Utils;
use strict;
use warnings;
use Carp;
our $VERSION = '0.01';


sub build_context {
    
    my $context = {
        
        'start' => sub {
            my ( $self, $param ) = @_;
            my $tag      = $self->{ns} . $param->{ element };
            my $attr_ref = $param->{ attr };
            
            $self->__push__( sub {
                # start building the return string
                my $return .= $self->__tab__ . q{<}.$tag;
                
                # any spec attrs?
                if ( $attr_ref->{ _xmlns_ } ) {
                    $return .= sprintf(' xmlns:%s="%s"', $self->{namespace}, $attr_ref->{ _xmlns_ } );
                    delete $attr_ref->{ _xmlns_ };
                }

                # build attributes string
                for my $k ( keys %{ $attr_ref } ) { 
                    $return .= sprintf( ' %s%s="%s"', $self->{attr_ns}, $k, $attr_ref->{$k} );  
                }
                
                $return .= q{>} . $self->{cr};
                $self->__inc__;
                
                return $return;
            });
            
        },
        
        'end' => sub {
            my ( $self, $param ) = @_;
            my $tag = $self->{ns} . $param->{ element };
            
            $self->__push__( sub { 
                $self->__dec__;
                $self->__tab__ . q{</}.$tag.q{>} . $self->{cr}
            });
        },
        
        'element' => sub {
            my ( $self, $param ) = @_;
            my $tag  = $self->{ns} . $param->{ element };
            my $text = $param->{text};
            $text    = $self->__cdatax__( $text )  if $self->{ cdata };
            
            my $attrib = q{};
            for my $k ( keys %{ $param->{ attr } } ) { 
                $attrib .= sprintf( ' %s%s="%s"', $self->{attr_ns}, $k, $param->{attr}->{$k} );  
            }
            
            $self->__push__( sub {
                $self->__tab__ . q{<}.$tag.$attrib.q{>}.$text.q{</}.$tag.q{>} . $self->{cr} 
            });
        },
    };
    
    return $context;
}


sub get_args {
    my ( %arg ) = @_;
    $arg{ns}      = defined $arg{namespace}      ? $arg{namespace} . q{:}         : q{};
    $arg{attr_ns} = defined $arg{attr_namespace} ? ( $arg{attr_namespace} . ':' ) : q{};
    $arg{attr_ns} = $arg{qualifiedAttrib}        ? $arg{ns}                       : $arg{attr_ns};
    $arg{cr}      = $arg{ newline }              ? "\n"                           : q{}; 
    $arg{cdata} ||= 0;   
    return %arg;
}

1;

__END__

=head1 NAME

Builder::XML::Utils - Internal Builder XML Utils

=head1 VERSION

Version 0.01

=cut



=head1 SYNOPSIS

TBD

=head1 EXPORT

None.

=head1 FUNCTIONS

=head2 build_context

=head2 get_args


=head1 AUTHOR

Barry Walsh C<< <draegtun at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-builder at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Builder>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Builder::XML::Utils


You can also look for information at:  L<Builder>

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

See L<Builder>


=head1 COPYRIGHT & LICENSE

Copyright 2008 Barry Walsh (Draegtun Systems Ltd), all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
