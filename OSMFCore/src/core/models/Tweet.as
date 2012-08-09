package core.models
{
	public class Tweet extends ModelBase
	{
		/**
		 * Constructor
		 */
		public function Tweet()
		{
		}
		
		/**
		 * @public
		 */
		[Bindable]
		public var content:String;
		
		/**
		 * @public
		 */
		public var date:String;
		
		/**
		 * @public
		 */
		[Bindable]
		public var author:String;

		/**
		 * @public
		 */
		public var avatar:String;
		
		/**
		 * @public
		 */
		[Bindable]
		public var pending:Boolean = false;
		
	}
	
}