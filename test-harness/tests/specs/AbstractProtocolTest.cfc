/**
 * My BDD Test
 */
component extends="coldbox.system.testing.BaseTestCase" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	/**
	 * executes before all suites+specs in the run() method
	 */
	function beforeAll(){
	}

	/**
	 * executes after all suites+specs in the run() method
	 */
	function afterAll(){
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Abstract Protocol", function(){
			beforeEach( function( currentSpec ){
				// Define the properties for the protocol.
				props = { APIKey : "this_is_my_postmark_api_key" };

				debug( props );

				protocol = createMock( "cbmailservices.models.AbstractProtocol" ).init( props );
			} );

			it( "can be created correctly", function(){
				// We want to check that all the properties we've handed it have been set.
				for ( var key in props ) {
					expect( protocol.propertyExists( key ) ).toBeTrue(
						"The propery (#key#) doesn't appear to have been set in the protocol."
					);
				}
			} );

			it( "can handle the property methods", function(){
				protocol.setProperty( "test", "test" );
				expect( protocol.getProperty( "test" ) ).toBe( "test" );
				expect( protocol.getProperty( "bogus", "test" ) ).toBe( "test" );
				expect( function(){
					property.getProperty( "bogussss" );
				} ).toThrow();
			} );
		} );
	}

}
