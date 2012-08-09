package core.controllers
{
	import com.comscore.osmf.ComscorePlugin;
	
	import core.env.*;
	import core.events.CoreEvent;
	import core.plugins.ad.AdPluginInfo;
	import core.plugins.annotation.AnnotationPlugin;
	import core.plugins.tracking.NativeTrackingPlugin;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	import org.osmf.events.MediaFactoryEvent;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfoResource;
	import org.osmf.media.URLResource;
	import org.osmf.smil.SMILPluginInfo;

	public class PluginController extends EventDispatcher
	{
		/**
		 * The reference of MediaFactory
		 */
		protected var factory:MediaFactory;

		/**
		 * @protected
		 * 
		 * A fake reference to the SMILPlugin
		 */
		protected var smilPlugin:SMILPluginInfo;
		
		/**
		 * @protected
		 * 
		 * A fake reference to the AdPlugin
		 */
		protected var adPlugin:AdPluginInfo;
		
		/**
		 * @protected
		 * 
		 * A fake reference to the comment plugin
		 */
		protected var annotationPlugin:AnnotationPlugin;

		/**
		 * @protected
		 * 
		 * A fake reference to the tracking plugin
		 */
		protected var trackingPlugin:NativeTrackingPlugin;		
		
		/**
		 * @protected
		 * 
		 * A fake reference to the ComScore plugin
		 */
		protected var comScorePlugin:ComscorePlugin;

		/**
		 * @protected
		 * 
		 * Indicates whether the ad plugin has been loaded
		 */
		public var adPluginLoaded:Boolean = false;
		
		/**
		 * @protected
		 * 
		 * Indicates whether the Conviva plugin has been loaded
		 */
		public var convivaPluginLoaded:Boolean = false;
		
		/**
		 * @protected
		 * 
		 * Indicates whether the ComScore plugin has been loaded
		 */
		public var comscorePluginLoaded:Boolean = false;
		
		/**
		 * @protected
		 * 
		 * Indicates whether the Nielsen plugin has been loaded
		 */
		public var nielsenPluginLoaded:Boolean = false;
		
		/**
		 * @public
		 * 
		 * The total number of external plugins
		 */
		public var numExternalPlugins:Number = 0;
		
		/**
		 * @public
		 * 
		 * The number of reported plugins
		 */
		protected var numReportedPlugins:Number = 0;
		
		/**
		 * @public
		 * 
		 * Register an external plugin
		 */
		public function registerPlugin(uri:String):void{
			numExternalPlugins += 1;
		}
		
		/**
		 * @public
		 * 
		 * Return true if all the external plugins are enabled. If one of them is disabled, then return false
		 */
		public function get isExternalPluginsEnabled():Boolean{
			return PluginPolicy.enableConviva || PluginPolicy.enableComscore || PluginPolicy.enableNielsen;
		}
		
		/**
		 * @public
		 * 
		 * Check the number of external plugins that have reported their status. Broadcast a CoreEvent.PLUGIN_LOADED
		 * when the number reaches numExternalPlugins (despite the status is successful or not)
		 */
		public function reportStatus():void{
			numReportedPlugins += 1;
			
			if(numReportedPlugins >= numExternalPlugins){
				var evt:CoreEvent = new CoreEvent(CoreEvent.EXTERNAL_PLUGIN_LOADED);
				dispatchEvent(evt);
				
				factory.removeEventListener(MediaFactoryEvent.PLUGIN_LOAD, onPluginLoaded);
				factory.removeEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, onPluginLoadError);			
			}
		}

		/**
		 * @protected
		 * Load those "built-in" plugins. These plugins should have no additional requirements for metadata or parameters 
		 */
		protected function loadBuiltInPlugin(source:String):void
		{
			var pluginResource:MediaResourceBase;
			var pluginInfoRef:Class = getDefinitionByName(source) as Class;
			pluginResource = new PluginInfoResource(new pluginInfoRef);
			
			factory.loadPlugin(pluginResource);
		}
		
		/**
		 * @public
		 * 
		 * Load plugins
		 */
		public function executeLoad():void{
			// Load all class based or SWC based plugins
			loadBuiltInPlugin("org.osmf.smil.SMILPluginInfo");
			loadBuiltInPlugin("core.plugins.ad.AdPluginInfo");
			loadBuiltInPlugin("core.plugins.tracking.NativeTrackingPluginInfo");
			loadBuiltInPlugin("core.plugins.annotation.AnnotationPluginInfo");
			loadBuiltInPlugin("com.comscore.osmf.ComscorePluginInfo");
			
			// Load external plugins (*.swf). These plugins must register themselves so that either successed loading or not, we could 
			// retrieve their status. 
			if(isExternalPluginsEnabled){
				// If you have external plugins to load, you should do it here
				if(PluginPolicy.enableConviva)
					loadConvivaPlugin();	
			}
			else{
				// If no external plugin specified, we will broadcast a CoreEvent and load the playlist directly
				var evt:CoreEvent = new CoreEvent(CoreEvent.EXTERNAL_PLUGIN_LOADED);
				dispatchEvent(evt);
			}
			
		}

		/**
		 * @protected
		 * 
		 * Load Conviva LivePass plugin
		 */
		protected function loadConvivaPlugin():void{
			trace("[Conviva] Attempting to load LivePass...");
			
			registerPlugin(Conviva.CONVIVA_NAMESPACE);
			
			var res:URLResource = new URLResource(Conviva.pluginUrl);
			var livePassMetadata:Dictionary = new Dictionary();
			livePassMetadata["serviceUrl"] = Conviva.serverUrl;
			livePassMetadata["customerId"] = Conviva.customerId;
			livePassMetadata["livePassNotifier"] = livePassCallback;
			
			res.addMetadataValue("http://www.conviva.com", livePassMetadata);
			factory.loadPlugin(res);
		}
		
		/**
		 * @protected
		 * 
		 * The callback function that is triggered by Conviva LivePass
		 */
		protected function livePassCallback(evt:Object):void{
			if (evt.code == 0) { 
				trace("[Conviva] LivePass has been initialized");
				convivaPluginLoaded = true;
			} 
			else { 
				trace("[Conviva] LivePass initialization failed");
				convivaPluginLoaded = false;
			}
			
			reportStatus();
		}
		
		/**
		 * @protected
		 * 
		 * Invoked when a plugin is loaded
		 */
		protected function onPluginLoaded(evt:MediaFactoryEvent):void{
			// Notify that the ad plugin has been loaded
			if(evt.resource is PluginInfoResource)
				if((evt.resource as PluginInfoResource).pluginInfo is AdPluginInfo)
					adPluginLoaded = true;
		}
		
		/**
		 * @protected
		 * 
		 * Invoked when an error happened while trying to load plugins
		 */
		protected function onPluginLoadError(evt:MediaFactoryEvent):void{
			if(evt.resource is URLResource){
				var pluginUrl:String = (evt.resource as URLResource).url
				trace("[PluginController] Loading failed at: " + pluginUrl);
				
				switch(pluginUrl){
					case Conviva.pluginUrl:
						convivaPluginLoaded = false;
						reportStatus();
						break;
				}
			}
		}

		/**
		 * Constructor
		 */
		public function PluginController(factory:MediaFactory, target:IEventDispatcher=null)
		{
			super(target);
			
			this.factory = factory;
			
			factory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD, onPluginLoaded, false, 0, true);
			factory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, onPluginLoadError, false, 0, true);			
		}
	}
}