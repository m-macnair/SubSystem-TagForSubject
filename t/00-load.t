#!perl -T
#Template test structure
use 5.006;
use strict;
use warnings;
use Test::More;
use Test::Exception;

my $module = $1 || 'SubSystem::TagForSubject';
use_ok( $module ) || BAIL_OUT "Failed to use $module : [$!]";

my $obj = new_ok( $module );
PLACEHOLDERS:{
	for my $method (
		qw/
			get_set_id_for_2d_tag
			get_set_id_for_3d_tag
			get_set_id_for_subject_3d_tag_int
			get_set_id_for_subject_3d_tag_string
			update_subject
			update_subject_3d_tag
		/
	) {
		ok( $obj->can( $method ) ) or die( "object can't $method" );
		dies_ok( sub { $obj->$method }, 'Place holder wrapper dies' );
		my $placeholder = "_$method";
		ok( $obj->can( $placeholder ) ) or die( "object can't _$method" );
		throws_ok( sub { $obj->$placeholder }, qr/not implemented/, 'Place holder dies correctly' );
	}
}




done_testing();
