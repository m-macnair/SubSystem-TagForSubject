
package SubSystem::TagForSubject::CachedDB;
use strict;
use 5.006;
use warnings;
use base qw/
  SubSystem::CachedDB::DBI
  SubSystem::TagForSubject
  /;

=head1 NAME
	SubSystem::TagForSubject - Assign arbitrary tags ids to arbitrary subject ids, use a cache and DBI
	Version 0.01
=cut

our $VERSION = '0.01';

=head1 SYNOPSIS
	Use DBI and a cache to implement the TagForSubject critical path
=head1 EXPORT
	None
=head1 SUBROUTINES/METHODS
=head2 Facilitators
	Specific to this module
=head3 _init
	Separate class instantiation and configuration for when that's a good idea
=cut

# TODO
# parametised table names

sub _init {
	my ( $self, $conf ) = @_;
	my $cdb_init = SubSystem::CachedDB::DBI::_init( $self, $conf );
	return $cdb_init unless $cdb_init->{pass};
	my $ifp_init = SubSystem::TagForSubject::_init( $self, $conf );
	return $ifp_init unless $ifp_init->{pass};

	my @table_caches = qw/
	  _2d_tags_value_to_id
	  /;
	$self->mk_accessors( @table_caches );
	$self->init_cache_for_accessors( \@table_caches );

	return {pass => 1};
}

=head2 Place holders Overwrites
	Replacing CachedDB private methods with 'actually do something'
=cut

=head3 _update_subject
	
=cut

# TODO implement switch for 3d tags
sub _update_subject {
	my ( $self, $subject_id, $p ) = @_;

	#should have done it this way from the start
	my $sth = $self->_preserve_sth( "subject.update()" );
	unless ( $sth ) {
		$sth = $self->_preserve_sth(
			"subject.update()",
			"update subjects 
				set 
					has_2d = ?, 
					has_3d = ?
				where id = ?"
		);
	}
	$sth->execute( $p->{has_2d}, $p->{has_3d}, $subject_id );
	return {pass => 1};
}

=head3 _update_subject_3d_tag
	
=cut

sub _update_subject_3d_tag {
	my ( $self, $p ) = @_;
	die( 'not implemented' );
}

=head3 _get_set_id_for_2d_tag
	
=cut

sub _get_set_id_for_2d_tag {

	my ( $self, $tag_string ) = @_;

	# :D
	$self->id_for_value( '_2d_tags', $tag_string );
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

=head3 assign_2d_tags
	
=cut

# TODO prevent duplicates

sub _add_2d_tags {
	my ( $self, $subject_id, $tag_ids, $p ) = @_;

	my $add_sth = $self->_subject_2d_tags_add_sth();

	for ( @{$tag_ids} ) {
		$add_sth->execute( $subject_id, $_ );
	}
	$self->_commit();

	return {pass => 1};
}

sub _subject_2d_tags_add_sth {
	my ( $self ) = @_;
	$self->_preserve_sth( "subject_2d_tags.add()", "insert into subject_2d_tags (subject_id, _2d_tag_id ) values (?,?) " ) unless $self->_preserve_sth( "subject_2d_tags.add()" );
	return $self->_preserve_sth( "subject_2d_tags.add()" );
}

=head3 _set_2d_tags
	
=cut

sub _set_2d_tags {
	my ( $self, $subject_id, $tag_ids, $p ) = @_;

	$self->_preserve_sth( "subject_2d_tags.clear()", "delete from subject_2d_tags where subject_id = ?" ) unless $self->_preserve_sth( "subject_2d_tags.clear()" );

	my $clear_sth = $self->_preserve_sth( "subject_2d_tags.clear()" );
	$clear_sth->execute( $subject_id );
	$self->_commit();
	my $add_sth = $self->_subject_2d_tags_add_sth();

	for ( @{$tag_ids} ) {
		$add_sth->execute( $subject_id, $_ );
	}
	$self->_commit();

	return {pass => 1};
}

=head3 _set_2d_tags
	
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

# TODO do exception handling for DB when duplicate
sub _new_subject {
	my ( $self, $subject_id, $p ) = @_;

	if ( $subject_id ) {
		my $sth = $self->_preserve_sth( "subject.new_from_old()" );
		unless ( $sth ) {
			$sth = $self->_preserve_sth( "subject.new_from_old()", "insert into subjects (id,has_2d,has_3d) values (?,?,?)" );
		}
		$sth->execute( $subject_id, $p->{has_2d}, $p->{has_3d} );
		return $self->_last_insert();
	}

	my $sth = $self->_preserve_sth( "subject.new()" );
	unless ( $sth ) {
		$sth = $self->_preserve_sth( "subject.new()", "insert into subjects (has_2d,has_3d) values (?,?)" );
	}

	$sth->execute( $p->{has_2d}, $p->{has_3d} );
	return $self->_last_insert();

}

# TODO cache
sub _get_subject {
	my ( $self, $subject_id, $p ) = @_;

	my $sth = $self->_preserve_sth( "subject.find_from_id()" ) || $self->_preserve_sth( "subject.find_from_id()", "select * from subjects where id = ?" );
	$sth->execute( $subject_id );
	if ( my $row = $sth->fetchrow_hashref() ) {
		return {pass => 'href', href => $row};
	}

	return {fail => 'not_found', not_found => "Subject [$subject_id] not found"};

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
