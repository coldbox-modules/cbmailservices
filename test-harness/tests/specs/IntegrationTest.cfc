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
		describe( "Integration", function(){
			beforeEach( function( currentSpec ){
				setup();
			} );

			it( "can leverage our mixin helpers", function(){
				var e = execute( "main.index" );
				expect( e.getPrivateValue( "mailResults" ).error ).toBeFalse();
			} );
		} );
	}

}
