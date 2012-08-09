package polkit
{
	import core.models.ModelBase;
	
	public class Policy extends ModelBase
	{
		/**
		 * @public
		 * 
		 * The display name, not to be confused as keys
		 */
		[Bindable]
		public var name:String;
		
		/**
		 * @public
		 */
		[Bindable]
		public var key:String;
		
		/**
		 * @public
		 */
		[Bindable]
		public var value:Object;
		
		/**
		 * @public
		 */
		public var kind:String = PolicyKind.NUMERIC_OR_STRING;
		
		/**
		 * @public
		 */
		[Bindable]
		public var description:String = "Description Not Available";
		
		/**
		 * @public
		 * 
		 * If kind is "enumerable", then this array provides possible values
		 */
		public var enumerableItems:Array = [];
		
		/**
		 * Constructor
		 */
		public function Policy()
		{
			super();
		}		
	}
}