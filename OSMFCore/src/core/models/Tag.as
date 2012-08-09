package core.models
{
	public class Tag extends ModelBase
	{
		/**
		 * @public
		 */
		public var name:String;
		
		/**
		 * @public
		 */
		public var numClips:Number = 0;
		
		/**
		 * Constructor
		 */
		public function Tag()
		{
			super();
		}
		
		/**
		 * @public
		 */
		public function parseXml(tagXml:XML):void{
			id = String(tagXml.id);
			name = String(tagXml.name);
		}
		
	}
}