package controllers
{
	import core.controllers.OSMFController;
	import core.models.ModelBase;
	
	import flash.display.StageAspectRatio;
	import flash.events.EventDispatcher;
	
	import views.MainView;
	import views.PlayerView;
	
	public class UIController extends EventDispatcher
	{
		/**
		 * @private
		 */
		public var mainView:MainView;
		
		/**
		 * @private
		 */
		public var playerView:PlayerView;
		
		/**
		 * @private
		 */
		public var playerController:PlayerController = new PlayerController();
		
		/**
		 * @private
		 */
		private static var _uiController:UIController;
		
		/**
		 * @private
		 */
		public static function get uiController():UIController
		{
			return initialize();
		}
		
		/**
		 * @private
		 */
		public static function initialize():UIController
		{
			if (_uiController == null){
				_uiController = new UIController();
			}
			return _uiController;
		}
		
		/**
		 * @constructor
		 */
		public function UIController()
		{
			super();
			if( _uiController != null ) throw new Error("Error:UIController already initialised.");
			if( _uiController == null ) _uiController = this;
		}
		
		/**
		 * @public
		 */
		public function init():void{
			playerController.playerView = playerView;
			playerController.init();
		}
		
		/**
		 * @public
		 */
		public function startPlayback(resource:ModelBase):void{
			mainView.visible = false;
			playerView.visible = true;

			// Go to landscape mode
			playerView.stage.setAspectRatio(StageAspectRatio.LANDSCAPE);
			
			playerController.resource = resource;
		}
		
		/**
		 * @public
		 */
		public function exitPlayback():void{
			OSMFController.osmfController.stop();
			
			mainView.visible = true;
			playerView.visible = false;
			
			mainView.onOrientationChange(null);
		}
		
	}
}