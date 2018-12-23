package SubSystem::TagForSubject;
use strict;
use 5.006;
use warnings;
use base qw(Class::Accessor);
__PACKAGE__->mk_accessors( qw/tag_divider tag_3d_divider / );

=head1 NAME
	SubSystem::TagForSubject - Assign arbitrary tags ids to arbitrary subject ids, somehow
=head1 VERSION
	Version 0.01
=cut

# TODO
# fix wrapper heads

our $VERSION = '0.01';

=head1 SYNOPSIS
	TODO
=head1 EXPORT
	None
=head1 SUBROUTINES/METHODS
=head2 Facilitators
	N/A
=cut

sub _init {
	my ( $self, $conf ) = @_;
	$self->tag_divider( ' ' )    unless $self->tag_divider;
	$self->tag_3d_divider( ':' ) unless $self->tag_3d_divider;
	return {pass => 1};
}

=head2 Critical Path
	'The thing we want to do'
=cut

=head3 subject_2d_tags
	Given an existing subject id and an arbitrarily separated tag string, 
	split the string and pass to add_2d_tags as id and array ref of tag ids 

=cut

sub subject_2d_tags {
	my ( $self, $subject_id, $tag_string, $p ) = @_;

	Carp::croak( "No subject_id provided" ) unless $subject_id;

	$tag_string = lc( $tag_string );
	my $tag_ids = [];
	my $tag_map = {};
	for ( split( $self->tag_divider, $tag_string ) ) {
		my $tag_id = $self->get_set_id_for_2d_tag( $_ );
		unless ( $tag_map->{$_} ) {
			push( @{$tag_ids}, $tag_id );
			$tag_map->{$_} = $tag_id;
		}
	}
	$self->assign_2d_tags( $subject_id, $tag_ids, $p );
	$self->update_subject(
		$subject_id,
		{
			has_2d => 1,
		}
	);
	return {pass => 'subject_id', subject_id => $subject_id, tag_map => $tag_map};
}

=head2 Wrappers
	add_2d_tags
	assign_3d_tags
	get_set_id_for_subject
	get_set_id_for_2d_tag
	get_set_id_for_3d_tag
	get_set_id_for_subject_3d_tag_int
	get_set_id_for_subject_3d_tag_string
	
	update_subject
	update_subject_3d_tag
=cut

=head2 get_set_subject
	W/o a subject_id, generate new id and return { pass => $id };
	With a subject_id, generate new id and return { pass => $id , new => 1 };
	With a subject_id, if exists return { pass => $id , old => 1 };
	Should usually be the only way new subjects are created, but reality
	
=cut

sub get_set_subject {
	my ( $self, $subject_id, $p ) = @_;

	if ( $subject_id ) {

		my $existing = $self->get_subject( $subject_id );
		if ( $existing->{pass} ) { #'href'
			return {
				pass => $existing->{href}->{id},
				old  => 1,
			};
		} elsif ( $existing->{fail} eq 'not_found' ) {
			return {
				pass => $self->new_subject( $subject_id, $p ),
				new  => 1,
			};
		} else {
			Carp::croak( "Unhandled failure in get_subject : $existing->{ $existing->{fail} }" );
		}
	}

	return {pass => $self->new_subject( $subject_id, $p ),};
}

=head3 get_subject
	get the full details of this subject as a href
=cut

sub get_subject {
	my ( $self, $subject_id, $p ) = @_;
	Carp::croak( "No subject_id provided" ) unless $subject_id;
	return $self->_get_subject( $subject_id, $p );
}

=head3 new_subject
	only ever for new subjects, even if the id is supplied 
=cut

sub new_subject {
	my ( $self, $subject_id, $p ) = @_;
	return $self->_new_subject( $subject_id, $p );
}

=head3 assign_2d_tags
	Given an existing subject id and an array ref of tag ids:
		default: Add to existing tag set (_add_2d_tags)
		$p->{set} : set as the definitive tags for the subject (_set_2d_tags)
		$p->{remove} : remove these tags from the subject (_remove_2d_tags)
	
=cut

sub assign_2d_tags {
	my ( $self, $subject_id, $tag_ids, $p ) = @_;
	Carp::croak( "No subject_id provided" ) unless $subject_id;
	Carp::croak( "Tag ids not supplied as array" ) unless ref( $tag_ids ) eq 'ARRAY';

	if ( $p->{set} ) {
		return $self->_set_2d_tags( $subject_id, $tag_ids, $p );
	} elsif ( $p->{remove} ) {
		return $self->_remove_2d_tags( $subject_id, $tag_ids, $p );
	}

	# There's an argument to adding either a warning or a carp for 'assign no tags' here
	return $self->_add_2d_tags( $subject_id, $tag_ids, $p );
}

=head3 assign_3d_tags
	
=cut

sub assign_3d_tags {
	my ( $self, $p ) = @_;
	return $self->_assign_3d_tags( $p );
}

=head3 get_set_id_for_2d_tag
	
=cut

sub get_set_id_for_2d_tag {
	my ( $self, $tag ) = @_;
	Carp::croak( "No tag supplied" ) unless defined( $tag );
	$tag = lc( $tag );
	return $self->_get_set_id_for_2d_tag( $tag );
}

=head3 get_set_id_for_3d_tag
	
=cut

sub get_set_id_for_3d_tag {
	my ( $self, $p ) = @_;
	return $self->_get_set_id_for_3d_tag( $p );
}

=head3 get_set_id_for_subject_3d_tag_int
	
=cut

sub get_set_id_for_subject_3d_tag_int {
	my ( $self, $p ) = @_;
	return $self->_get_set_id_for_subject_3d_tag_int( $p );
}

=head3 get_set_id_for_subject_3d_tag_string
	
=cut

sub get_set_id_for_subject_3d_tag_string {
	my ( $self, $p ) = @_;
	return $self->_get_set_id_for_subject_3d_tag_string( $p );
}

=head1 Generated Functions

=cut

=head3 update_subject
	
=cut

sub update_subject {
	my ( $self, $subject_id, $p ) = @_;
	Carp::croak( 'update_subject() without $subject_id' ) unless $subject_id;

	return $self->_update_subject( $subject_id, $p );
}

=head3 update_subject_3d_tag
	
=cut

sub update_subject_3d_tag {
	my ( $self, $p ) = @_;
	return $self->_update_subject_3d_tag( $p );
}

sub get_set_id_for_subject {
	my ( $self, $p ) = @_;
	return $self->_get_set_id_for_subject( $p );
}

=head2 Place holders
	Should all be replaced in child classes 

	_update_subject
	_update_subject_3d_tag
	_get_set_id_for_2d_tag
	_get_set_id_for_3d_tag
	_get_set_id_for_subject_3d_tag_int
	_get_set_id_for_subject_3d_tag_string

=cut

=head3 _get_set_id_for_2d_tag
	
=cut

sub _update_subject {
	my ( $self, $p ) = @_;
	die( 'not implemented' );
}

=head3 _get_set_id_for_2d_tag
	
=cut

sub _update_subject_3d_tag {
	my ( $self, $p ) = @_;
	die( 'not implemented' );
}

=head3 _get_set_id_for_2d_tag
	
=cut

sub _get_set_id_for_2d_tag {
	my ( $self, $p ) = @_;
	die( 'not implemented' );
}

=head3 _get_set_id_for_3d_tag
	
=cut

sub _get_set_id_for_3d_tag {
	my ( $self, $p ) = @_;
	die( 'not implemented' );
}

=head3 _get_set_id_for_subject_3d_tag_int
	
=cut

sub _get_set_id_for_subject_3d_tag_int {
	my ( $self, $p ) = @_;
	die( 'not implemented' );
}

=head3 _get_set_id_for_subject_3d_tag_string
	
=cut

sub _get_set_id_for_subject_3d_tag_string {
	my ( $self, $p ) = @_;
	die( 'not implemented' );
}

=head3 add_2d_tags
	
=cut

sub _add_2d_tags {
	my ( $self, $subject_id, $tag_ids, $p ) = @_;
	die( 'not implemented' );
}

=head3 _set_2d_tags
	
=cut

sub _set_2d_tags {
	my ( $self, $subject_id, $tag_ids, $p ) = @_;
	die( 'not implemented' );
}

=head3 _remove_2d_tags
	
=cut

sub _remove_2d_tags {
	my ( $self, $subject_id, $tag_ids, $p ) = @_;
	die( 'not implemented' );
}

=head3 assign_3d_tags
	
=cut

sub _assign_3d_tags {
	my ( $self, $p ) = @_;
	die( 'not implemented' );
}

sub _get_set_id_for_subject {
	my ( $self, $p ) = @_;
	die( 'not implemented' );
}

=head3 _get_subject
	
=cut

sub _get_subject {
	my ( $self, $subject_id, $p ) = @_;
	die( 'not implemented' );
}

=head3 _new_subject
	
=cut

sub _new_subject {
	my ( $self, $subject_id, $p ) = @_;
	die( 'not implemented' );
}

=head1 AUTHOR

mmacnair, C<< <mmacnair at cpan.org> >>

=head1 BUGS

	TODO Bugs

=head1 SUPPORT

	TODO Support

=head1 ACKNOWLEDGEMENTS
	TODO 

=head1 LICENSE AND COPYRIGHT

Copyright 2018 mmacnair.

This program is distributed under the (Revised) BSD License:
L<http://www.opensource.org/licenses/BSD-3-Clause>

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

* Neither the name of mmacnair's Organization
nor the names of its contributors may be used to endorse or promote
products derived from this software without specific prior written
permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1;
