
package com.comscore.osmf
{
	import flash.display.Sprite;
	
	import org.osmf.media.PluginInfo;

	/**
	 * The root level object of the Caption Plugin.
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.0
	 *  @productversion OSMF 1.0
	 */
	public class ComscorePlugin extends Sprite
	{
		/**
		 * Constructor.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function ComscorePlugin()
		{
			_pluginInfo = new ComscorePluginInfo();
		}
		
		/**
		 * Gives the player the PluginInfo.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function get pluginInfo():PluginInfo
		{
			return _pluginInfo;
		}
		
		private var _pluginInfo:ComscorePluginInfo;
	}
}
