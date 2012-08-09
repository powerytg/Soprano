package core.plugins.tracking
{
	import flash.display.Sprite;
	import flash.system.Security;
	
	public class NativeTrackingPlugin extends Sprite
	{
		/**
		 * @protected
		 */
		protected var _pluginInfo:NativeTrackingPluginInfo;
		
		/**
		 * Constructor
		 */
		public function NativeTrackingPlugin()
		{
			super();
			
			// Allow any SWF that loads this SWF to access objects and
			// variables in this SWF.
			Security.allowDomain(this.root.loaderInfo.loaderURL);
			
			_pluginInfo = new NativeTrackingPluginInfo();
		}
		
		/**
		 * @public
		 */
		public function get pluginInfo():NativeTrackingPluginInfo{
			return _pluginInfo;
		}
	}
}