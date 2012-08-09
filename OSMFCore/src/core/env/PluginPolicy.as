package core.env
{
	public class PluginPolicy
	{
		/**
		 * @public
		 * 
		 * Whether to use native (naive) tracking
		 */
		static public var enableNativeTracking:Boolean = true;
		
		/**
		 * @public
		 * 
		 * Whether to enable Conviva plugin
		 */
		static public var enableConviva:Boolean = false;
		
		/**
		 * @public
		 * 
		 * Whether to enable ComScore plugin
		 */
		static public var enableComscore:Boolean = false;
		
		/**
		 * @public
		 * 
		 * Whether to enable Nielsen plugin
		 */
		static public var enableNielsen:Boolean = false;
		
		/**
		 * @public
		 * 
		 * whether to allow comments
		 */
		static public var enableComments:Boolean = true;

		/**
		 * Constructor
		 */
		public function PluginPolicy()
		{
		}
	}
}