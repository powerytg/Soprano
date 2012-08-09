package controllers
{
	import activities.playbackActivities.PlaybackMenuView;
	
	import core.controllers.MetricsController;
	import core.controllers.OSMFController;
	import core.events.AdModeEvent;
	import core.events.PlaylistEvent;
	import core.models.ModelBase;
	import core.models.Playlist;
	import core.models.ResourceType;
	import core.plugins.ad.events.AdEvent;
	import core.plugins.annotation.events.AnnotationEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.core.IVisualElement;
	import mx.events.EffectEvent;
	import mx.events.FlexEvent;
	
	import org.osmf.events.TimeEvent;
	
	import spark.filters.BlurFilter;
	
	import views.PlayerView;
	import views.chrome.AdModeIndicator;
	import views.chrome.LoadingIndicator;
	import views.chrome.MetricsIndicator;
	import views.chrome.PauseIndicator;
	import views.supportClasses.AnnotationWidget;
	
	public class PlayerController extends EventDispatcher
	{
		/**
		 * @public
		 * 
		 * Reference to PlayerView
		 */
		public var playerView:PlayerView;
		
		/**
		 * @private
		 */
		private static var _playerController:PlayerController;
		
		/**
		 * @private
		 */
		public static function get playerController():PlayerController
		{
			return initialize();
		}
		
		/**
		 * @private
		 */
		public static function initialize():PlayerController
		{
			if (_playerController == null){
				_playerController = new PlayerController();
			}
			return _playerController;
		}
		
		/**
		 * @private
		 */
		private var osmfController:OSMFController = OSMFController.osmfController;
		
		/**
		 * @private
		 * 
		 * It's important to initialize the metrics controller so that it could properly
		 * add its listeners to the OSMF media player.
		 */
		private var metricsController:MetricsController = MetricsController.metricsController;
		
		/**
		 * @private
		 */
		private var loadingRing:LoadingIndicator;
		
		/**
		 * @private
		 */
		private var pauseRing:PauseIndicator;
		
		/**
		 * @private
		 */
		private var chromeTimer:Timer;
		
		/**
		 * @private
		 */
		private var adModeChooser:AdModeIndicator;
		
		/**
		 * @private
		 */
		private var metricsIndicator:MetricsIndicator;
		
		/**
		 * @private
		 */
		private var _resource:ModelBase;
		
		/**
		 * @private
		 */
		private var activeAnnotationWidgets:ArrayCollection = new ArrayCollection();
		
		/**
		 * @private
		 */
		public function get resource():ModelBase
		{
			return _resource;
		}
		
		/**
		 * @private
		 */
		public function set resource(value:ModelBase):void
		{
			if(value != null){
				_resource = value;
				
				var resourceType:String =  (_resource is Playlist) ? ResourceType.PLAYLIST : ResourceType.CLIP;
				osmfController.loadResource(_resource.id, resourceType);
			}
		}
		
		/**
		 * @private
		 */
		private var isPlayingAd:Boolean = false;
		
		/**
		 * @private
		 */
		private var isDraggingTimeline:Boolean = false;		

		/**
		 * @private
		 */
		private var isChoosingAdMode:Boolean = false;		

		/**
		 * @private
		 */
		private var menuView:PlaybackMenuView;
		
		/**
		 * @constructor
		 */
		public function PlayerController()
		{
			super();
			if( _playerController != null ) throw new Error("Error:PlayerController already initialised.");
			if( _playerController == null ) _playerController = this;
		}
		
		/**
		 * @private
		 */
		public function init():void{
			playerView.videoContainer.container = osmfController.mediaContainer;
			
			osmfController.addEventListener(AdModeEvent.NEED_TO_CHOOSE_AD_MODE, onNeedToChooseAdMode, false, 0, true);
			osmfController.addEventListener(PlaylistEvent.SHOW_LOADING_SCREEN, showLoadingScreen, false, 0, true);
			osmfController.addEventListener(PlaylistEvent.REMOVE_LOADING_SCREEN, removeLoadingScreen, false, 0, true);
			osmfController.addEventListener(PlaylistEvent.CURRENT_CLIP_CHANGE, onCurrentClipChange, false, 0, true);
			osmfController.addEventListener(AdEvent.STATE_CHANGE, onAdStateChange, false, 0, true);
			osmfController.addEventListener(AnnotationEvent.CUE_POINT_REACHED, onAnnotationReached, false, 0, true);
			osmfController.addEventListener(AnnotationEvent.CUE_POINT_EXPIRED, onAnnotationExpired, false, 0, true);
			
			osmfController.player.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, onCurrentTimeChange, false, 0, true);
			osmfController.player.addEventListener(TimeEvent.DURATION_CHANGE, onDurationChange, false, 0, true);
			
			osmfController.bootstrap();
			
			playerView.overlayGroup.addEventListener(MouseEvent.CLICK, onScreenClick, false, 0, true);
			playerView.scrubbar.addEventListener(FlexEvent.CHANGE_START, onSeekingStart, false, 0, true);
			playerView.scrubbar.addEventListener(FlexEvent.CHANGE_END, onSeekingEnd, false, 0, true);
			playerView.nextButton.addEventListener(MouseEvent.CLICK, onNextButtonClick, false, 0, true);
			playerView.closeButton.addEventListener(MouseEvent.CLICK, onCloseButtonClick, false, 0, true);
			playerView.magicButton.addEventListener(MouseEvent.CLICK, onMagicButtonClick, false, 0, true);
			playerView.graphButton.addEventListener(MouseEvent.CLICK, onMetricsButtonClick, false, 0, true);
		}
		
		/**
		 * @private
		 */
		private function onCurrentClipChange(evt:PlaylistEvent):void{
			playerView.scrubbar.maximum = osmfController.currentClip.duration;
		}
		
		/**
		 * @private
		 */
		private function onScreenClick(evt:MouseEvent):void{
			if(isPlayingAd || isChoosingAdMode)
				return;
			
			if(pauseRing){
				removePauseScreen();
				osmfController.play();
				return;
			}
			
			if(playerView.upperChrome.visible){
				hideChrome();
				
				osmfController.pause();
				showPauseScreen();
			}
			else
				showChrome();
		}
		
		/**
		 * @private
		 */
		private function onNeedToChooseAdMode(evt:AdModeEvent):void{
			isChoosingAdMode = true;
			adModeChooser = new AdModeIndicator();
			
			if(osmfController.playlist.clips.length > 0)
				adModeChooser.previewUrl = osmfController.playlist.clips[0].hdPreviewUrl;

			adModeChooser.width = playerView.width;
			adModeChooser.height = playerView.height;
			playerView.overlayGroup.addElement(adModeChooser);
			
			adModeChooser.longModeButton.addEventListener(MouseEvent.CLICK, onAdModeLongButtonClick, false, 0, true);
			adModeChooser.shortModeButton.addEventListener(MouseEvent.CLICK, onAdModeShortButtonClick, false, 0, true);
			adModeChooser.returnButton.addEventListener(MouseEvent.CLICK, onAdModeReturnButtonClick, false, 0, true);
		}
		
		/**
		 * @private
		 */
		private function onAdModeReturnButtonClick(evt:MouseEvent):void{
			closeAdModeChooser();
			UIController.uiController.exitPlayback();
		}

		/**
		 * @private
		 */
		private function onAdModeShortButtonClick(evt:MouseEvent):void{
			closeAdModeChooser();	
			
			osmfController.playlist.useLongAd = false;
			osmfController.playClip(osmfController.playlist.clips[0]);
		}

		/**
		 * @private
		 */
		private function onAdModeLongButtonClick(evt:MouseEvent):void{
			closeAdModeChooser();
			
			osmfController.playlist.useLongAd = true;
			osmfController.playClip(osmfController.playlist.clips[0]);
		}

		/**
		 * @private
		 */
		private function closeAdModeChooser():void{
			adModeChooser.closeAnimation.addEventListener(EffectEvent.EFFECT_END, onAdModeCloseAnimationEnd);
			adModeChooser.closeAnimation.play();
		}
			
		/**
		 * @private
		 */
		private function onAdModeCloseAnimationEnd(evt:EffectEvent):void{
			isChoosingAdMode = false;
			
			adModeChooser.longModeButton.removeEventListener(MouseEvent.CLICK, onAdModeLongButtonClick);
			adModeChooser.shortModeButton.removeEventListener(MouseEvent.CLICK, onAdModeShortButtonClick);
			adModeChooser.returnButton.removeEventListener(MouseEvent.CLICK, onAdModeReturnButtonClick);
			adModeChooser.closeAnimation.removeEventListener(EffectEvent.EFFECT_END, onAdModeCloseAnimationEnd);
			
			playerView.overlayGroup.removeElement(adModeChooser);
			adModeChooser = null;				
		}
		
		/**
		 * @private
		 */
		public function showLoadingScreen(evt:PlaylistEvent = null):void{
			if(loadingRing)
				return;
			
			loadingRing = new LoadingIndicator();
			loadingRing.horizontalCenter = 0;
			loadingRing.verticalCenter = 0;
			playerView.overlayGroup.addElement(loadingRing);
			
			if(playerView.upperChrome.visible)
				hideChrome();
		}
		
		/**
		 * @private
		 */
		public function removeLoadingScreen(evt:PlaylistEvent = null):void{
			if(loadingRing){
				if(playerView.overlayGroup.containsElement(loadingRing))
					playerView.overlayGroup.removeElement(loadingRing);
				
				loadingRing = null;
			}
		}

		/**
		 * @private
		 */
		private function showPauseScreen(evt:PlaylistEvent = null):void{
			if(pauseRing)
				return;
			
			pauseRing = new PauseIndicator();
			pauseRing.horizontalCenter = 0;
			pauseRing.verticalCenter = 0;
			playerView.overlayGroup.addElement(pauseRing);
			
			if(playerView.upperChrome.visible)
				hideChrome();
		}
		
		/**
		 * @private
		 */
		private function removePauseScreen(evt:PlaylistEvent = null):void{
			if(pauseRing){
				if(playerView.overlayGroup.containsElement(pauseRing))
					playerView.overlayGroup.removeElement(pauseRing);
				
				pauseRing = null;
			}
		}
		
		/**
		 * @private
		 */
		private function showChrome():void{
			if(playerView.upperChrome.visible)
				return;
		
			playerView.showChromeAnimation.play();
			
			// Start a timer
			if(chromeTimer)
				chromeTimer.stop();
			
			chromeTimer = new Timer(3000);
			chromeTimer.addEventListener(TimerEvent.TIMER, onChromeTimerExpired);
			chromeTimer.start();
		}
		
		/**
		 * @private
		 */
		private function onChromeTimerExpired(evt:TimerEvent):void{
			if(chromeTimer){
				chromeTimer.stop();
				chromeTimer = null;
			}
			
			if(playerView.upperChrome.visible)
				hideChrome();
			
		}
		
		/**
		 * @private
		 */
		private function hideChrome():void{
			if(!playerView.upperChrome.visible)
				return;
			
			playerView.hideChromeAnimation.play();
		}
		
		/**
		 * @private
		 */
		private function onAdStateChange(evt:AdEvent):void{
			if(evt.state == AdEvent.AD_ACTIVATED){
				isPlayingAd = true;
			}
			else{
				isPlayingAd = false;
			}
		}

		/**
		 * @private
		 */
		private function onCurrentTimeChange(evt:TimeEvent):void{
			if(isDraggingTimeline)
				return;
			
			playerView.scrubbar.value = evt.time;	
		}
	
		/**
		 * @private
		 */
		private function onDurationChange(evt:TimeEvent):void{
//			playerView.scrubbar.maximum = evt.time;
		}
	
		/**
		 * @private
		 */
		private function onSeekingStart(evt:FlexEvent):void{
			isDraggingTimeline = true;
		}
		
		/**
		 * @private
		 */
		private function onSeekingEnd(evt:FlexEvent):void{
			isDraggingTimeline = false;
			if(osmfController.player.canSeek)
				osmfController.seekTo(playerView.scrubbar.value);
		}
		
		/**
		 * @private
		 */
		private function onNextButtonClick(evt:MouseEvent):void{
			osmfController.playClip(osmfController.getNextClip());
		}
		
		/**
		 * @private
		 */
		private function onCloseButtonClick(evt:MouseEvent):void{
			UIController.uiController.exitPlayback();
		}
		
		/**
		 * @private
		 */
		private function onMagicButtonClick(evt:MouseEvent):void{
			showMenuView();
		}
		
		/**
		 * @private
		 */
		private function onMetricsButtonClick(evt:MouseEvent):void{
			if(metricsIndicator){
				playerView.overlayGroup.removeElement(metricsIndicator);
				metricsIndicator = null;
			}
			else{
				metricsIndicator = new MetricsIndicator();
				metricsIndicator.top = 25;
				metricsIndicator.left = 15;
				playerView.overlayGroup.addElement(metricsIndicator);	
			}
		}
		
		/**
		 * @public
		 */
		public function showMenuView():void{
			if(menuView)
				return;
			
			hideChrome();
			osmfController.pause();
			
			playerView.videoContainer.filters = [new BlurFilter(25, 25)];
			
			menuView = new PlaybackMenuView();
			menuView.percentWidth = 100;
			menuView.percentHeight = 100;
			playerView.addElement(menuView);
			
		}
		
		/**
		 * @public
		 */
		public function closeMenuView():void{
			menuView.deck.removeAll();
			
			if(playerView.containsElement(menuView)){
				playerView.removeElement(menuView);
				menuView = null;
				
				playerView.videoContainer.filters = [];
				osmfController.play();
			}
		}
		
		/**
		 * @private
		 */
		private function onAnnotationReached(evt:AnnotationEvent):void{
			var widget:AnnotationWidget;
			for each(widget in activeAnnotationWidgets){
				if(widget.annotation == evt.currentAnnotation)
					return;
			}
			
			widget = new AnnotationWidget();
			widget.annotation = evt.currentAnnotation;
			playerView.overlayGroup.addElement(widget);
			activeAnnotationWidgets.addItem(widget);
		}

		/**
		 * @private
		 */
		private function onAnnotationExpired(evt:AnnotationEvent):void{
			var widget:AnnotationWidget;
			for each(var w:AnnotationWidget in activeAnnotationWidgets){
				if(w.annotation == evt.currentAnnotation){
					widget = w;
					break;
				}
			}
			
			if(!widget)
				return;

			if(playerView.overlayGroup.containsElement(widget))
				playerView.overlayGroup.removeElement(widget);
			
			activeAnnotationWidgets.removeItemAt(activeAnnotationWidgets.getItemIndex(widget));
		}

		/**
		 * @private
		 */
		private function removeAllAnnotations():void{
			var widgets:Array = [];
			activeAnnotationWidgets.removeAll();
			for(var i:uint = 0; i < playerView.overlayGroup.numElements; i++){
				var e:IVisualElement = playerView.overlayGroup.getElementAt(i);
				if(e is AnnotationWidget)
					widgets.push(e);
			}
			
			for each(var annotationWidget:IVisualElement in widgets){
				playerView.overlayGroup.removeElement(annotationWidget);
			}
		}
		
	}
}