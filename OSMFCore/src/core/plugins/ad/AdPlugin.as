package core.plugins.ad
{
	import flash.display.Sprite;
	import flash.system.Security;	
	import org.osmf.media.PluginInfo;
	
	public class AdPlugin extends Sprite
	{
		/**
		 * @protected
		 */
		protected var _pluginInfo:AdPluginInfo;

		public function AdPlugin()
		{
			super();

			// Allow any SWF that loads this SWF to access objects and
			// variables in this SWF.
			Security.allowDomain(this.root.loaderInfo.loaderURL);
			
			_pluginInfo = new AdPluginInfo();
		}

		/**
		 * Gives the player the PluginInfo object.
		 */
		public function get pluginInfo():PluginInfo
		{
			return _pluginInfo;
		}

	}
}