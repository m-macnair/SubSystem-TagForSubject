#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;
use Test::Exception;
use File::Slurp;
use Data::Dumper;

my $module = $1 || 'SubSystem::TagForSubject::CachedDB';
use_ok( $module ) || BAIL_OUT "Failed to use $module : [$!]";

dies_ok( sub { new( $module ) } ); #passed a test earlier w/o db init
my $obj;
SQLITE: {
	
	my $db_file = time . "_test_file.sqlite";

	# 	next;
	$obj = new_ok(
		$module,
		[
			{
				dsn => [
					"dbi:SQLite:$db_file",
					undef, undef,
					{
						AutoCommit                 => 1,
						RaiseError                 => 1,
						sqlite_see_if_its_a_number => 1,
					}

				],
			}
		]
	);
	my $sql = read_file( "./etc/sqlite_schema.sql" );
	for ( split( $/, $sql ) ) {
		ok( $obj->dbh->do( $_ ) );
	}

	is( $obj->_get_set_id_for_2d_tag( "funky" ), 1 );
	my $twelve_result = $obj->get_set_subject( 12 );
	is( ref($twelve_result) , 'HASH' );
	is( $twelve_result->{pass} , 12 );
	
	my $old_twelve_result = $obj->get_set_subject( 12 );
	is( ref($old_twelve_result) , 'HASH' );
	ok( $old_twelve_result->{old});
	
	my $bad_twelve_result = $obj->new_subject( 12 );
	is( ref($bad_twelve_result) , 'HASH' );
	ok( $bad_twelve_result->{fail});
	
	
	ok( $obj->assign_2d_tags( 1, "funky fresh beats" ), 'Can assign 2d tags');

	
	
}


done_testing();
