package core.plugins.ad.elements
{
	import core.controllers.OSMFController;
	import core.env.Environment;
	import core.env.PluginPolicy;
	import core.models.Clip;
	import core.plugins.ad.events.AdEvent;
	import core.plugins.ad.events.AdProxyEvent;
	import core.plugins.ad.events.DurationProxyElementEvent;
	import core.plugins.ad.models.Ad;
	import core.plugins.ad.models.AdMetadata;
	import core.plugins.ad.utils.AdFactory;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import org.osmf.elements.ProxyElement;
	import org.osmf.events.LoaderEvent;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.events.SeekEvent;
	import org.osmf.events.TimelineMetadataEvent;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.CuePoint;
	import org.osmf.metadata.CuePointType;
	import org.osmf.metadata.TimelineMetadata;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	import org.osmf.traits.SeekTrait;
	import org.osmf.traits.TimeTrait;
	import org.osmf.vast.loader.VASTLoadTrait;
	import org.osmf.vast.loader.VASTLoader;
	import org.osmf.vast.media.VASTMediaGenerator;
	
	
	public class AdProxyElement extends ProxyElement
	{
		/**
		 * @protected
		 * 
		 * This timer is used to monitor the availability of proxiedElement. Will expire after that proxiedElement has been set
		 */
		protected var timer:Timer;
		
		/**
		 * @protected
		 * 
		 * A loader used to communicate with the ad server and download orchestrated ad manifest xml
		 */
		protected var loader:URLLoader;
		
		/**
		 * @private
		 */
		private var liveLoader:URLLoader;
		
		/**
		 * @protected
		 * 
		 * The collection of ad value objects
		 */
		protected var adByCuePoint:Dictionary = new Dictionary(true);
		
		/**
		 * @protected
		 * 
		 * The original media element that is being proxied
		 */
		protected var originalElement:MediaElement;
		
		/**
		 * @protected
		 * 
		 * A factory used to create ad elements
		 */
		protected var factory:MediaFactory;
		
		/**
		 * @protected
		 * @see controllers.OSMFController
		 * 
		 * currentClip
		 */		
		protected var clip:Clip;
		
		/**
		 * @protected
		 */
		protected var sanityChecked:Boolean = false;
		
		/**
		 * @private
		 */
		private var currentAd:Ad;
		
		/**
		 * @private
		 */
		private var liveAdCuePointTime:Number = 0;
		
		/////////////////////////////////////////////////////
		// Initializer
		/////////////////////////////////////////////////////		
		
		/**
		 * Constructor
		 */
		public function AdProxyElement(proxiedElement:MediaElement=null)
		{
			super(proxiedElement);
			
			// The factory is used to create VAST elements
			factory = new DefaultMediaFactory();
			
			// Wait until proxiedElement is available
			timer = new Timer(100);
			timer.addEventListener(TimerEvent.TIMER, onWaitProxyAvailable);
			timer.start();			
		}
		
		/**
		 * @protected
		 * 
		 * Invoked every 100ms, just to check whether the proxied element is available. Expires right after that
		 */
		protected function onWaitProxyAvailable(evt:TimerEvent):void{
			if(proxiedElement != null){
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER, onWaitProxyAvailable);
				
				// Store the proxied element into originalElement
				originalElement = proxiedElement;
				// Listen to seek events, so that if user clicked pass an ad point, we could forct jumping back and play the ad
				var seekTrait:SeekTrait = originalElement.getTrait(MediaTraitType.SEEK) as SeekTrait;
				if(seekTrait){
					originalElement.addEventListener(SeekEvent.SEEKING_CHANGE, onSeek, false, 0, true);
				}
				else
					originalElement.addEventListener(MediaElementEvent.TRAIT_ADD, onSeekTraitAdded, false, 0, true);
				
				// Load the ads from server. We need to provide the clip information, though
				var metadata:AdMetadata = proxiedElement.getMetadata(AdMetadata.NS_AD_METADATA) as AdMetadata;
				clip = metadata.clip;
				
				var request:URLRequest;
				
				if(clip.live)
					request = new URLRequest(Environment.serverUrl + "/clips.orchestrate_live_ad.xml?id=" + clip.id); 
				else if(metadata.useLongAd)
					request = new URLRequest(Environment.serverUrl + "/clips.orchestrate_long_ad.xml?id=" + clip.id);
				else{
					var url:String = Environment.serverUrl + "/clips.orchestrate.xml?id=" + metadata.clip.id;
					if(!isNaN(clip.startTime) && clip.startTime != -1)
						url += "&startTime=" + clip.startTime.toString();
					if(!isNaN(clip.endTime) && clip.endTime != -1)
						url += "&endTime=" + clip.endTime.toString();
					
					request = new URLRequest(url);
				}
				
				loader = new URLLoader();
				loader.addEventListener(Event.COMPLETE, onOrchestrationInfoLoaded);
				
				loader.load(request);
			}
		}
		
		/**
		 * @protected
		 * 
		 * Invoked when successfully retrieved the orchestration info from the Ad server
		 */
		protected function onOrchestrationInfoLoaded(evt:Event):void{
			var loader:URLLoader = evt.target as URLLoader;
			loader.removeEventListener(Event.COMPLETE, onOrchestrationInfoLoaded);
			
			try{
				var result:XML = XML(loader.data);
			}
			catch(e:Error){
				trace(e.message);
			}
			
			// The timeline is used to monitor the cue points for the original element
			var timeline:TimelineMetadata = getMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE) as TimelineMetadata;
			if(!timeline){
				timeline = new TimelineMetadata(originalElement);
				addMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE, timeline);
			}
			timeline.addEventListener(TimelineMetadataEvent.MARKER_TIME_REACHED, onCuePointReached, false, 0, true);
			
			// We'll need to parse the ads from the xml
			clip.ads = new Vector.<Ad>();
			var ad:Ad;
			var adIndex:uint = 0;
			for each(var adXml:XML in result.ads.children()){
				ad = AdFactory.createAd(adXml, adIndex);
				adByCuePoint[ad.cuePoint] = ad;
				clip.ads.push(ad);
				adIndex += 1;
			}
			
			// If the first ad is a preroll (occur at time 0), then we need to make sure it's fully loaded.
			// Otherwise, loading could happen in background, and in this case, we'll start video playback immediately
			var orchestrationEvent:AdProxyEvent = new AdProxyEvent(AdProxyEvent.ORCHESTRATED);
			orchestrationEvent.clip = clip;			
			if(clip.ads.length == 0){
				clip.dispatchEvent(orchestrationEvent);
			}
			else{
				var firstAd:Ad = clip.ads[0];
				if(firstAd.cuePoint.time == 0){
					firstAd.addEventListener(AdProxyEvent.AD_LOADED, onFirstAdLoaded, false, 0, true);
					firstAd.addEventListener(AdProxyEvent.AD_LOAD_ERROR, onFirstAdLoaded, false, 0, true);
				}
				else{
					clip.dispatchEvent(orchestrationEvent);
				}
				
				// Load ads
				for each(ad in clip.ads){
					loadAd(ad);
				}
			}
			
			// [Bug Fix] If a video stream has PlayTrait at very beginning, then sometimes the cue point at time 0 would not get triggered.
			// In this case, we need to "manually" trigger this cue point
			if(originalElement.hasTrait(MediaTraitType.PLAY)){
				var playTrait:PlayTrait = originalElement.getTrait(MediaTraitType.PLAY) as PlayTrait;
				playTrait.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onStateChange, false, 0, true);
			}
			else
				originalElement.addEventListener(MediaElementEvent.TRAIT_ADD, onPlayTraitAdded, false, 0, true);
			
		}
		
		/**
		 * @private
		 */
		private function onFirstAdLoaded(evt:AdProxyEvent):void{
			evt.ad.removeEventListener(AdProxyEvent.AD_LOADED, onFirstAdLoaded);
			evt.ad.removeEventListener(AdProxyEvent.AD_LOAD_ERROR, onFirstAdLoaded);
			
			// Notify the OSMFController that the first ad has been loaded
			var orchestrationEvent:AdProxyEvent = new AdProxyEvent(AdProxyEvent.ORCHESTRATED);
			orchestrationEvent.clip = clip;			
			clip.dispatchEvent(orchestrationEvent);
		}
		
		
		/////////////////////////////////////////////////////
		// Sanity Check on First Run
		/////////////////////////////////////////////////////
		
		/**
		 * @protected
		 * 
		 * Ensure the first ad is played (if the cue point is 0).
		 */
		protected function firstAdSanityCheck():void{
			if(sanityChecked)
				return;
			
			sanityChecked = true;
			
			if(clip.ads.length > 0 && clip.ads[0].active && clip.ads[0].cuePoint.time == 0){
				playAd(clip.ads[0]);
			}
		}
		
		/**
		 * @protected
		 * 
		 * Invoked when a PlayTrait is added to the proxied element.
		 * 
		 * We will do some sanity check to force play the first ad (if its cue point is 0) by injecting a hook to this event
		 */
		protected function onPlayTraitAdded(evt:MediaElementEvent):void{
			if(evt.traitType == MediaTraitType.PLAY){
				originalElement.removeEventListener(MediaElementEvent.TRAIT_ADD, onPlayTraitAdded);
				firstAdSanityCheck();
			}
		}
		
		/**
		 * @protected
		 * 
		 * Will only be invoked if the video has PlayTrait from the very beginning.
		 * If it happens that OSMF hasn't been able to capture CuePoint at time 0 (at which we play the first ad), then we will force playing the ad at the beginning of 
		 * playback
		 */
		protected function onStateChange(evt:PlayEvent):void{
			var playTrait:PlayTrait = originalElement.getTrait(MediaTraitType.PLAY) as PlayTrait;
			playTrait.removeEventListener(PlayEvent.PLAY_STATE_CHANGE, onStateChange);			
			if(evt.playState == PlayState.PLAYING)
				firstAdSanityCheck();
		}
		
		/////////////////////////////////////////////////////
		// Loading VAST2 Ads
		/////////////////////////////////////////////////////
		
		/**
		 * @protected
		 */
		protected function injectConvivaMetadata(resource:URLResource, ad:Ad):void{
			var convivaMetadata:Dictionary = new Dictionary(true);
			convivaMetadata["objectId"] = ad.id;
			convivaMetadata["isLive"] = false;
			
			var convivaTags:Object = new Object();
			convivaTags["isAd"] = true;
			convivaTags["id"] = ad.id;
			convivaTags["type"] = ad.vastType == "linear" ? "takeover" : "banner";
			convivaTags["show"] = clip.id;
			
			convivaMetadata["tags"] = convivaTags;
			
			resource.addMetadataValue("http://www.conviva.com", convivaMetadata);
		}
		
		/**
		 * @private
		 */
		private var adByLoader:Dictionary = new Dictionary(true);
		
		/**
		 * @protected
		 * 
		 * Load an ad
		 */
		protected function loadAd(ad:Ad):void{
			if(ad.vastType == 'NonLinear')
				return;
			
			// Create VAST resource
			var vastResource:URLResource = new URLResource(ad.url);
			
			// If the Conviva plugin is enabled and loaded, then we put some metadata for it
			if(PluginPolicy.enableConviva)
				injectConvivaMetadata(vastResource, ad);
			
			var vastLoader:VASTLoader = new VASTLoader();
			var vastLoadTrait:VASTLoadTrait = new VASTLoadTrait(vastLoader, vastResource);
			adByLoader[vastLoader] = ad;
			vastLoader.addEventListener(LoaderEvent.LOAD_STATE_CHANGE, onVASTLoaderStateChange, false, 0, true);
			vastLoader.load(vastLoadTrait);
		}
		
		/**
		 * @protected
		 * 
		 * Load an ad for the live stream
		 */
		protected function loadLiveAd(cuePointTime:Number):void{
			liveAdCuePointTime = cuePointTime;
			
			var request:URLRequest = new URLRequest(Environment.serverUrl + "/clips.orchestrate_live_ad.xml?id=" + clip.id);
			liveLoader = new URLLoader();
			liveLoader.addEventListener(Event.COMPLETE, onLiveAdLoaded, false, 0, true);
			liveLoader.load(request);
		}
		
		/**
		 * @private
		 */
		private function onLiveAdLoaded(evt:Event):void{
			if(liveLoader)
				liveLoader.removeEventListener(Event.COMPLETE, onLiveAdLoaded);
			
			var result:XML = XML(loader.data);
			var adXml:XMLList = XMLList(result.child("ads"));
			
			// The timeline is used to monitor the cue points for the original element
			var timeline:TimelineMetadata = getMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE) as TimelineMetadata;
			
			// We'll need to parse the ads from the xml
			var ad:Ad = new Ad();
			ad.id = String(adXml.ad[0].id);
			ad.name = String(adXml.ad[0].name);
			ad.url = String(adXml.ad[0].url);
			ad.vastType = String(adXml.ad[0].vast_type) == "linear" ? VASTMediaGenerator.PLACEMENT_LINEAR : VASTMediaGenerator.PLACEMENT_NONLINEAR;
			
			// Dynamically inject a cue point to the next possible ad point
			ad.cuePoint = new CuePoint(CuePointType.ACTIONSCRIPT, liveAdCuePointTime, "adPointLive", null);
			loadAd(ad);
			clip.ads.push(ad);
		}
		
		/**
		 * @private
		 */
		private function onVASTLoaderStateChange(evt:LoaderEvent):void{
			var ad:Ad;
			
			if(evt.newState == LoadState.READY){
				ad = adByLoader[evt.loader] as Ad;
				var vastLoadTrait:VASTLoadTrait = evt.loadTrait as VASTLoadTrait;
				
				var vastMediaGenerator:VASTMediaGenerator = new VASTMediaGenerator(null, factory);				
				var vastElements:Vector.<MediaElement> = vastMediaGenerator.createMediaElements(vastLoadTrait.vastDocument, 
					ad.vastType);
				
				// Because a VASTElement may contain several non-visual elements, we need to pick up the one we want (a single proxy element)			
				var adLoadEvent:AdProxyEvent;
				for each(var mediaElement:MediaElement in vastElements){
					if(mediaElement is ProxyElement){
						ad.duration = Number((evt.loadTrait as VASTLoadTrait).vastDocument['adTagVASTDuration']);
						ad.media = new DurationProxyElement(mediaElement, ad.duration);
						
						// Create a cue point for it
						var timeline:TimelineMetadata = getMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE) as TimelineMetadata;
						timeline.addMarker(ad.cuePoint);
						
						break;
					}
				}
				
				ad.loaded = true;
				
				adLoadEvent = new AdProxyEvent(AdProxyEvent.AD_LOADED);
				adLoadEvent.ad = ad;
				ad.dispatchEvent(adLoadEvent);
				
				evt.loader.removeEventListener(LoaderEvent.LOAD_STATE_CHANGE, onVASTLoaderStateChange);
				delete adByLoader[evt.loader];
			}
			else if(evt.newState == LoadState.LOAD_ERROR){
				ad = adByLoader[evt.loader] as Ad;
				ad.loaded = false;
				
				adLoadEvent = new AdProxyEvent(AdProxyEvent.AD_LOAD_ERROR);
				adLoadEvent.ad = ad;
				ad.dispatchEvent(adLoadEvent);
				
				evt.loader.removeEventListener(LoaderEvent.LOAD_STATE_CHANGE, onVASTLoaderStateChange);
				delete adByLoader[evt.loader];
			}
			
			
			
		}
		
		/////////////////////////////////////////////////////
		// Cue Point Handlers
		/////////////////////////////////////////////////////
		
		/**
		 * @protected
		 * 
		 * Invoked when an ad element is about to play
		 */
		protected function onCuePointReached(evt:TimelineMetadataEvent):void{
			// Accept only "ad*" cuepoints
			if((evt.marker as CuePoint).name.match(/^ad/) == null)
				return;
			
			// Find out the respective ad
			var ad:Ad = adByCuePoint[evt.marker as CuePoint];
			
			// Ignore if the ad is already inactive
			if(!ad || !ad.active || !ad.loaded)
				return;
			
			playAd(ad);
		}
		
		/**
		 * @protected
		 * 
		 * Invoked when an ad element finishes playing
		 */
		protected function onAdExpired(evt:DurationProxyElementEvent):void{
			// Force stoping the ad
			var playTrait:PlayTrait;
			if(proxiedElement != originalElement){
				playTrait = proxiedElement.getTrait(MediaTraitType.PLAY) as PlayTrait;
				if(playTrait)
					playTrait.stop();
			}
			
			// Switch back to the original media
			proxiedElement = this.originalElement;
			
			// Remove referene
			if(currentAd && currentAd.media){
				currentAd.media.removeEventListener(DurationProxyElementEvent.TIME_UP, onAdExpired);
				delete adByCuePoint[currentAd.cuePoint];
				
				var timeline:TimelineMetadata = getMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE) as TimelineMetadata;
				timeline.removeMarker(currentAd.cuePoint);
				
				var loadTrait:LoadTrait = currentAd.media.getTrait(MediaTraitType.LOAD) as LoadTrait;
				if(loadTrait)
					loadTrait.unload();
				
				currentAd.media = null;
			}
			
			// Fire an event to notify the front-end UI
			var event:AdEvent = new AdEvent(AdEvent.STATE_CHANGE);
			event.state = AdEvent.AD_DEACTIVATED;
			OSMFController.osmfController.dispatchEvent(event);	
			
			// For a live event, as long as the current ad expires, we'll need to prefetch another one.
			if(clip.live){
				// Clear all previous ad points
				clip.ads = new Vector.<Ad>();
				
				var timeTrait:TimeTrait = proxiedElement.getTrait(MediaTraitType.TIME) as TimeTrait; 
				loadLiveAd(timeTrait.currentTime + clip.liveAdInterval);
			}
		}
		
		/////////////////////////////////////////////////////
		// Playback Controlling
		/////////////////////////////////////////////////////
		
		/**
		 * @protected
		 * 
		 * Invoked when the ad element gains the play trait
		 */
		protected function onAdPlayTraitAdded(evt:MediaElementEvent):void{
			var playTrait:PlayTrait = proxiedElement.getTrait(MediaTraitType.PLAY) as PlayTrait;
			if(playTrait){
				playTrait.play();
				removeEventListener(MediaElementEvent.TRAIT_ADD, onAdPlayTraitAdded);
			}
		}
		
		/**
		 * @protected
		 * 
		 * Invoked when the original element gains the seek trait
		 */
		protected function onSeekTraitAdded(evt:MediaElementEvent):void{
			if(evt.traitType == MediaTraitType.SEEK){
				var seekTrait:SeekTrait = originalElement.getTrait(MediaTraitType.SEEK) as SeekTrait;
				seekTrait.addEventListener(SeekEvent.SEEKING_CHANGE, onSeek, false, 0, true);
			}
		}
		
		/**
		 * @protected
		 * 
		 * Play an ad
		 */
		protected function playAd(ad:Ad):void{
			// Ignore if ad is already inactive
			if(!ad.active || !ad.loaded){
				return;
			}
			
			ad.active = false;
			currentAd = ad;
			
			// Pause the original element
			var playTrait:PlayTrait = originalElement.getTrait(MediaTraitType.PLAY) as PlayTrait;
			if(playTrait && playTrait.canPause)
				playTrait.pause();
			
			// Start ad's timer
			proxiedElement = ad.media;
			(ad.media as DurationProxyElement).startTimer();
			ad.media.addEventListener(DurationProxyElementEvent.TIME_UP, onAdExpired, false, 0, true);
			
			// Switch to the ad element
			//			playTrait = proxiedElement.getTrait(MediaTraitType.PLAY) as PlayTrait;
			//			if(playTrait){
			//				playTrait.play();
			//			}
			//			else{
			//				addEventListener(MediaElementEvent.TRAIT_ADD, onAdPlayTraitAdded, false, 0, true);
			//			}
			
			// Fire an event to notify the front-end UI
			var event:AdEvent = new AdEvent(AdEvent.STATE_CHANGE);
			event.ad = ad;
			event.state = AdEvent.AD_ACTIVATED;
			OSMFController.osmfController.dispatchEvent(event);
		}
		
		/**
		 * @private
		 * 
		 * Dirty hack: For unknown reasons, I found I always end up with triggering two SEEK events with the exact timestamp, even though I'm quite sure
		 * I only called seeking functions once. Thus we must ignore the duplcated events
		 */
		private var currentSeekTime:Number = -1;
		
		/**
		 * @protected
		 * 
		 * Invoked when user try to seek on the scrub bar, will force play the nearest active ad
		 */
		protected function onSeek(evt:SeekEvent):void{
			// Ignore duplicated seeking events
			if(currentSeekTime != evt.time)
				currentSeekTime = evt.time;
			else
				return;
			
			// Find the nearest ad point (if any), and disable all previous ad points(if any)
			var nearestAd:Ad;
			for each(var ad:Ad in clip.ads){
				if(ad.cuePoint.time >= evt.time)
					break;
				else
					nearestAd = ad;
			}
			
			if(nearestAd && nearestAd.active){
				// Disable all ad points before nearestAd
				for each(ad in clip.ads){
					if(ad.cuePoint.time < nearestAd.cuePoint.time)
						ad.active = false;
				}
				
				// Play this nearest ad if it's active
				playAd(nearestAd);
			}
		}
		
		
	}
}