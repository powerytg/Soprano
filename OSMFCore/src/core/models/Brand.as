package core.models
{
	/**
	 * The Brand class describes video provider (companies) info
	 */
	public class Brand extends ModelBase
	{
		/**
		 * @public
		 */
		public var name:String;
		
		/**
		 * @public
		 */
		public var waterMarkUrl:String;
		
		/**
		 * Constructor
		 */
		public function Brand()
		{
			super();
		}
		
		/**
		 * @public
		 */
		public function parseXml(brandXml:XML):void{
			id = String(brandXml.id);
			name = String(brandXml.name);
		}
		
	}
}