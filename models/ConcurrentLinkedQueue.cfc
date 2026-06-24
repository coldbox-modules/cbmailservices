/**
 * *******************************************************************************
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * *******************************************************************************
 * ----
 * A concurrent non-blocking linked queue (FIFO) modeled after the Java counterpart.
 *
 * @author Luis Majano <lmajano@ortussolutions.com>
 * @see    https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/util/concurrent/ConcurrentLinkedQueue.html
 */
component accessors="true" {

	/**
	 * The native java ConcurrentLinkedQueue
	 */
	property name="jQueue";

	// Stupid ACF compiler bug.
	variables[ "contains" ] = variables.has;
	this[ "contains" ]      = variables.has;

	/**
	 * Constructor
	 *
	 * @list
	 */
	function init( any list = [] ){
		if ( isSimpleValue( arguments.list ) ) {
			arguments.list = listToArray( arguments.list );
		}

		variables.jQueue = createObject( "java", "java.util.concurrent.ConcurrentLinkedQueue" ).init();

		if ( arrayLen( arguments.list ) ) {
			variables.jQueue.addAll( arguments.list );
		}

		return this;
	}

	/**
	 * Inserts the specified element at the tail of this queue.
	 *
	 * @element The element to add to the queue
	 */
	ConcurrentLinkedQueue function add( required element ){
		variables.jQueue.add( arguments.element );
		return this;
	}

	/**
	 * Appends all of the elements in the specified collection to the end of this queue, in the order that they are returned by the specified collection's iterator.
	 *
	 * @collection An array collection to add into the queue as elements
	 */
	ConcurrentLinkedQueue function addAll( required array collection ){
		variables.jQueue.addAll( arguments.collection );
		return this;
	}

	/**
	 * Removes all of the elements from this queue. The queue will be empty after this call returns.
	 */
	ConcurrentLinkedQueue function clear(){
		variables.jQueue.clear();
		return this;
	}

	/**
	 * Creates and returns a copy of this object.
	 */
	ConcurrentLinkedQueue function clone(){
		return new ConcurrentLinkedQueue( this.toArray() );
	}

	/**
	 * Returns true if this queue contains the specified element.
	 */
	boolean function has( required element ){
		return variables.jQueue.contains( arguments.element );
	}

	/**
	 * Returns true if this collection contains all of the elements in the specified collection.
	 *
	 * @collection Collection to be checked for containment in this collection
	 *
	 * @return true if this collection contains all of the elements in the specified collection
	 */
	boolean function containsAll( required array collection ){
		return variables.jQueue.containsAll( arguments.collection );
	}

	/**
	 * Returns true if this queue contains no elements.
	 */
	boolean function isEmpty(){
		return variables.jQueue.isEmpty();
	}

	/**
	 * Returns an iterator over the elements in this queue in proper sequence.
	 */
	function iterator(){
		return variables.jQueue.iterator();
	}

	/**
	 * Inserts the specified element at the tail of this queue.
	 *
	 * @element The element to add at the tail
	 */
	ConcurrentLinkedQueue function offer( required element ){
		variables.jQueue.offer( arguments.element );
		return this;
	}

	/**
	 * Retrieves, but does not remove, the head of this queue, or returns null if this queue is empty.
	 *
	 * @return The head of this queue, or null if this queue is empty
	 */
	any function peek(){
		return variables.jQueue.peek();
	}

	/**
	 * Retrieves and removes the head of this queue, or returns null if this queue is empty.
	 *
	 * @return The head of this queue, or null if this queue is empty
	 */
	any function poll(){
		return variables.jQueue.poll();
	}

	/**
	 * Retrieves and removes the head of this queue. This method differs from poll only in that it throws an exception if this queue is empty.
	 * If you pass in the `element` argument, then we will try to remove the element from the queue instead.
	 *
	 * @element If passed, it will remove the element.
	 *
	 * @return The head of this queue
	 *
	 * @throws NoSuchElementException - if this queue is empty
	 */
	boolean function remove( any element ){
		if ( isNull( arguments.element ) ) {
			return variables.jQueue.remove();
		}
		return variables.jQueue.remove( arguments.element );
	}

	/**
	 * Removes all of this collection's elements that are also contained in the specified collection (optional operation).
	 *
	 * @collection The array of elements to remove
	 */
	boolean function removeAll( required array collection ){
		return variables.jQueue.removeAll( arguments.collection );
	}

	/**
	 * Retains only the elements in this collection that are contained in the specified collection (optional operation).
	 *
	 * @collection The array of elements to retain
	 */
	boolean function retainAll( required array collection ){
		return variables.jQueue.retainAll( arguments.collection );
	}

	/**
	 * Returns the number of elements in this queue.
	 */
	numeric function size(){
		return variables.jQueue.size();
	}

	/**
	 * Returns a Spliterator over the elements in this queue.
	 */
	any function spliterator(){
		return variables.jQueue.spliterator();
	}

	/**
	 * Returns a sequential Stream with this collection as its source.
	 */
	any function stream(){
		return variables.jQueue.stream();
	}

	/**
	 * Returns a possibly parallel Stream with this collection as its source. It is allowable for this method to return a sequential stream.
	 */
	any function parallelStream(){
		return variables.jQueue.parallelStream();
	}

	/**
	 * Returns an array containing all of the elements in this queue, in proper sequence.
	 *
	 * @native If true, then it returns a native CFML array, else a Java Array Collection
	 */
	array function toArray( boolean native = true ){
		var javaArray = variables.jQueue.toArray();
		if ( arguments.native ) {
			var cfArray = [];
			cfArray.append( javaArray, true );
			return cfArray;
		}
		return javaArray;
	}

	/**
	 * Returns a string representation of this collection.
	 * The string representation consists of a list of the collection's elements in
	 * the order they are returned by its iterator, enclosed in square brackets ("[]").
	 * Adjacent elements are separated by the characters ", " (comma and space).
	 * Elements are converted to strings as by String.valueOf(Object).
	 */
	string function toString(){
		return variables.jQueue.toString();
	}

}
