component extends="coldbox.system.testing.BaseTestCase" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	/**
	 * executes before all suites+specs in the run() method
	 */
	function beforeAll(){
		super.beforeAll();
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		describe( "Concurrent Linked Queue", function(){
			beforeEach( function( currentSpec ){
				queue = getInstance( "ConcurrentLinkedQueue@cbmailservices" );
			} );

			it( "can be created", function(){
				expect( queue ).toBeComponent();
			} );

			it( "can be created with a seeded array", function(){
				var results = queue.init( "1,2,3" );
				expect( results ).toBeComponent();
				expect( results.size() ).toBe( 3 );
			} );

			it( "can work with default methods", function(){
				queue = queue.init();
				queue.add( "luis" );
				queue.add( getInstance( "Mail@cbMailServices" ) );
				queue.addAll( [ 1, 2 ] );
				debug( queue.toString() );
				expect( queue.size() ).toBe( 4 );
				expect( queue.contains( 1 ) ).toBeTrue();
				expect( queue.isEmpty() ).toBeFalse();
				queue.clear();
				expect( queue.size() ).toBe( 0 );
				expect( queue.isEmpty() ).toBeTrue();
			} );

			it( "can insert elements at the tail of the queue", function(){
				var q = queue.addAll( [ 1, 2 ] ).offer( 4 );
				expect( q.peek() ).toBe( 1 );
				expect( q.size() ).toBe( 3 );
				expect( q.poll() ).toBe( 1 );
				expect( q.size() ).toBe( 2 );
			} );

			it( "can clone", function(){
				queue.addAll( [ 1, 2 ] );
				var q = queue.clone();
				expect( q.size() ).toBe( 2 );
			} );

			it( "can create iterators", function(){
				var i = queue.addAll( [ 1, 2 ] ).iterator();
				while ( i.hasNext() ) {
					expect( i.next() ).toBeNumeric();
				}
			} );
		} );
	}

}
