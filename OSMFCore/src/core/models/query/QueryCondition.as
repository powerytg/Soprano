package core.models.query
{
	import core.models.Tag;

	public class QueryCondition
	{
		/**
		 * @public
		 */
		public var keywords:String;

		/**
		 * @public
		 */
		public var year:Number;

		/**
		 * @public
		 */
		public var month:Number;

		/**
		 * @public
		 */
		public var tag:core.models.Tag = null;
		
		/**
		 * @public
		 */
		public var clearPreviousRecords:Boolean = false;
		
		/**
		 * Constructor
		 */
		public function QueryCondition()
		{
		}
	}
}