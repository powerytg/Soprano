package controllers
{
	import core.models.Tweet;
	
	import events.TwitterEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.LocationChangeEvent;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	import mx.collections.ArrayCollection;
	
	import org.iotashan.oauth.IOAuthSignatureMethod;
	import org.iotashan.oauth.OAuthConsumer;
	import org.iotashan.oauth.OAuthRequest;
	import org.iotashan.oauth.OAuthSignatureMethod_HMAC_SHA1;
	import org.iotashan.oauth.OAuthToken;
	import org.iotashan.utils.OAuthUtil;
	
	import spark.managers.PersistenceManager;
	
	public class TwitterController extends EventDispatcher
	{
		/**
		 * @private
		 */
		private var consumerKey:String = "dq77IMssIJOyIpeBiKpfw";
		
		/**
		 * @private
		 */
		private var consumerSecret:String = "CuHfljDe0ROOF5Jk8QOcE10hkkSdHvLu8RLsMDS34";

		/**
		 * @private
		 */
		private var requestTokenUrl:String = "https://api.twitter.com/oauth/request_token";
		
		/**
		 * @private
		 */
		private var authorizeUrl:String = "https://api.twitter.com/oauth/authorize";
		
		/**
		 * @private
		 */
		private var accessTokenUrl:String = "https://api.twitter.com/oauth/access_token";
		
		/**
		 * @private
		 */
		private var echoUrl:String = "http://web.me.com/delphi.you/PillowTalk/Success.html";

		/**
		 * @private
		 */
		private var searchUrl:String = "http://search.twitter.com/search.json";

		/**
		 * @private
		 */
		private var updateUrl:String = "https://api.twitter.com/1/statuses/update.json";
		
		/**
		 * @private
		 */
		private var scope:String = "http://web.me.com/delphi.you/";
		
		/**
		 * @private
		 */
		private var consumer:OAuthConsumer = new OAuthConsumer(consumerKey, consumerSecret);
		
		/**
		 * @private
		 */
		private var signature:IOAuthSignatureMethod = new OAuthSignatureMethod_HMAC_SHA1();
		
		/**
		 * @private
		 */
		private var requestToken:OAuthToken;

		/**
		 * @private
		 */
		private var accessToken:OAuthToken;

		/**
		 * @private
		 */
		public var webView:StageWebView = new StageWebView();
		
		/**
		 * @private
		 */
		private static var _twitterController:TwitterController;
		
		/**
		 * @private
		 */
		public static function get twitterController():TwitterController
		{
			return initialize();
		}
		
		/**
		 * @private
		 */
		public static function initialize():TwitterController
		{
			if (_twitterController == null){
				_twitterController = new TwitterController();
			}
			return _twitterController;
		}
		
		/**
		 * @constructor
		 */
		public function TwitterController()
		{
			super();
			if( _twitterController != null ) throw new Error("Error:TwitterController already initialised.");
			if( _twitterController == null ) _twitterController = this;
		}

		/**
		 * @public
		 */
		public function retrieveAccessTokenLocally():Boolean{
			var pm:PersistenceManager = new PersistenceManager();
			if(pm.load()){
				var accessTokenKey:Object = pm.getProperty("demoPlayer.accessToken.key");
				var accessTokenSecret:Object = pm.getProperty("demoPlayer.accessToken.secret");
				
				if(!accessTokenSecret || !accessTokenKey){
					trace("[TwitterController] local access token not found");
					return false;
				}
				else{
					accessToken = new OAuthToken(accessTokenKey.toString(), accessTokenSecret.toString());
					trace("[TwitterController] accessToken.key retrieved from local: " + accessToken.key);
					trace("[TwitterController] accessToken.secret retrieved from local:  " + accessToken.secret);

					return true;
				}
			}
			else{
				return false;
			}
			
			return false;
		}
		
		/**
		 * @public
		 */
		public function clearAccessTokenLocally():void{
			var pm:PersistenceManager = new PersistenceManager();
			pm.clear();
		}
		
		/**
		 * @public
		 */
		public function getRequestToken():void{
			var oauthRequest:OAuthRequest = new OAuthRequest(OAuthRequest.HTTP_MEHTOD_GET, requestTokenUrl, 
				null, consumer);
			
			var request:URLRequest = new URLRequest(oauthRequest.buildRequest(signature));
			
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onRequestTokenComplete, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onRequestTokenError, false, 0, true);
			loader.load(request);
		}

		/**
		 * @private
		 */
		private function onRequestTokenComplete(evt:Event):void{
			var loader:URLLoader = evt.currentTarget as URLLoader;
			requestToken = OAuthUtil.getTokenFromResponse(loader.data);
			
			trace("[TwitterController] requestToken.key = " + requestToken.key);
			trace("[TwitterController] requestToken.secret = " + requestToken.secret);

			authorize();
		}
		
		/**
		 * @private
		 */
		private function onRequestTokenError(evt:IOErrorEvent):void{
			var loader:URLLoader = evt.currentTarget as URLLoader;
			trace("[TwitterController] Request token denied " + loader.data);
		}
		
		/**
		 * @public
		 */
		public function authorize():void{
			webView.removeEventListener(LocationChangeEvent.LOCATION_CHANGE, onWebViewLocationChange);
			
			webView.viewPort = new Rectangle( 0, 0, webView.stage.stageWidth, webView.stage.stageHeight);
			
			webView.loadURL(authorizeUrl + "?oauth_token=" + requestToken.key);
			webView.addEventListener(LocationChangeEvent.LOCATION_CHANGE, onWebViewLocationChange);
		}
		
		/**
		 * @private
		 */
		private function onWebViewLocationChange(evt:LocationChangeEvent):void{
			if(evt.location.indexOf("delphi.you") == -1){
				// Denied
				trace("[TwitterController] Redirected to " + evt.location);
				webView.stage = null;
				return;
			}
			
			// Reqeust access token
			webView.stage = null;
			getAccessToken();
		}
		
		/**
		 * @private
		 */
		private function getAccessToken():void{
			var oauthRequest:OAuthRequest = new OAuthRequest(OAuthRequest.HTTP_MEHTOD_GET, accessTokenUrl, null, consumer, requestToken);
			var request:URLRequest = new URLRequest(oauthRequest.buildRequest(signature));
			
			// Invoking remote service with URLLoader
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onAccessTokenComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onAccessTokenError);
			loader.load(request);
		}
		
		/**
		 * @private
		 */
		private function onAccessTokenComplete(evt:Event):void{
			var loader:URLLoader = evt.currentTarget as URLLoader;
			accessToken = OAuthUtil.getTokenFromResponse(loader.data);
			
			trace("[TwitterController] accessToken.key = " + accessToken.key);
			trace("[TwitterController] accessToken.secret = " + accessToken.secret);
			
			// Store into local storage
			var pm:PersistenceManager = new PersistenceManager();
			pm.setProperty("demoPlayer.accessToken.key", accessToken.key);
			pm.setProperty("demoPlayer.accessToken.secret", accessToken.secret);
			trace("[TwitterController] access token stored");
		}
		
		/**
		 * @private
		 */
		private function onAccessTokenError(evt:IOErrorEvent):void{
			var loader:URLLoader = evt.currentTarget as URLLoader;
			if(loader.data.indexOf("denied") != -1){
				trace("[TwitterController] Access token denied");
				trace(loader.data);
			}
		}

		/**
		 * @public
		 * 
		 * Parameter "page" starts with 1
		 */
		public function search(queryTerm:String, page:Number = 1, perPage:Number = 10):void{
			var request:URLRequest = new URLRequest(searchUrl + "?q=" + queryTerm + "&rpp=" + perPage.toString() + "&page=" + page.toString());
			
			// Invoking remote service with URLLoader
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onSearchResult);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onSearchError);
			loader.load(request);
		}
		
		/**
		 * @private
		 */
		private function onSearchResult(evt:Event):void{
			var loader:URLLoader = evt.currentTarget as URLLoader;
			var result:ArrayCollection = new ArrayCollection();
			var page:Number = 1;
			
			try{
				var twitterResult:Object = JSON.parse(loader.data);
				var tweets:Array = twitterResult.results;
				page = Number(twitterResult.page);
				for each(var tweetObject:Object in tweets){
					var tweet:Tweet = new Tweet();
					tweet.id = tweetObject.id;
					tweet.author = tweetObject.from_user;
					tweet.content = tweetObject.text;
					
					result.addItem(tweet);
				}
			}
			catch(e:Error){
				trace(e.getStackTrace());
			}
			
			var event:TwitterEvent = new TwitterEvent(TwitterEvent.SEARCH_RESULT);
			event.page = page;
			event.tweets = result;
			dispatchEvent(event);
		}
		
		/**
		 * @private
		 */
		private function onSearchError(evt:IOErrorEvent):void{
			var loader:URLLoader = evt.currentTarget as URLLoader;
			trace(loader.data);
		}
		
		/**
		 * @public
		 */
		public function updateStatus(status:String):void{
			var oauthRequest:OAuthRequest = new OAuthRequest(OAuthRequest.HTTP_MEHTOD_POST, updateUrl, {status: status}, consumer, accessToken);
			var requestUrl:String = oauthRequest.buildRequest(signature);
			var request:URLRequest = new URLRequest(requestUrl);
			request.method = "POST";
			
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onUpdateComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onUpdateError);
			loader.load(request);
		}
	
		/**
		 * @private
		 */
		private function onUpdateError(evt:IOErrorEvent):void{
			dispatchEvent(new TwitterEvent(TwitterEvent.STATUS_UPDATE_FAILED));
			
			var loader:URLLoader = evt.currentTarget as URLLoader;
			trace(loader.data);
		}
		
		/**
		 * @private
		 */
		private function onUpdateComplete(evt:Event):void{
			var loader:URLLoader = evt.currentTarget as URLLoader;

			var tweetObject:Object = JSON.parse(loader.data);
			var tweet:Tweet = new Tweet();
			tweet.id = tweetObject.id;
			tweet.author = "me";
			tweet.content = tweetObject.text;

			var event:TwitterEvent = new TwitterEvent(TwitterEvent.STATUS_UPDATE_SUCCESS);
			event.tweet = tweet;
			dispatchEvent(event);
		}
	}
}