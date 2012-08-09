package core.controllers
{
	import core.env.Environment;
	import core.events.CommentEvent;
	import core.models.Clip;
	import core.models.Comment;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class CommentController extends EventDispatcher
	{
		/**
		 * @public
		 */
		public var clip:Clip;
		
		/**
		 * @public
		 */
		public var numPages:Number = 0;
		
		/**
		 * @public
		 */
		public var numPagesLoaded:Number = 0;
		
		/**
		 * @public
		 * 
		 * Total number of comments
		 */
		public var numItems:Number;

		/**
		 * @constructor
		 */
		public function CommentController()
		{
			super();
		}
		
		/**
		 * @public
		 */
		public function postComment(clip:Clip, content:String):void{
			var request:URLRequest = new URLRequest(Environment.serverUrl + "/clips.post_comment.xml?id=" + clip.id + "&content=" + escape(content));
			var loader:URLLoader = new URLLoader();
			
			loader.addEventListener(Event.COMPLETE, onPostSuccess, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onPostFault, false, 0, true);
			loader.load(request);
		}
		
		/**
		 * @private
		 */
		protected function onPostSuccess(evt:Event):void{
			var loader:URLLoader = evt.currentTarget as URLLoader;
			var result:XML = XML(loader.data);

			loader.removeEventListener(Event.COMPLETE, onPostSuccess);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onPostFault);

			var comment:Comment = new Comment();
			comment.id = String(result.id);
			comment.content = String(result.content);
			comment.date = String(result.date);
			
			if(clip)
				clip.comments.push(comment);
			
			var e:CommentEvent = new CommentEvent(CommentEvent.POST_SUCCESS);
			e.comment = comment; 
			dispatchEvent(e);
		}
		
		/**
		 * @private
		 */
		protected function onPostFault(evt:Event):void{
			var loader:URLLoader = evt.currentTarget as URLLoader;
			
			loader.removeEventListener(Event.COMPLETE, onPostSuccess);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onPostFault);

			trace("[CommentController] post failed");
			trace(loader.data);
			
			dispatchEvent(new CommentEvent(CommentEvent.POST_FAILED));
		}
		
		/**
		 * @public
		 */
		public function getComments(page:Number = 1, perPage:Number = 10):void{
			if(numPagesLoaded != 0 && numPagesLoaded >= numPages)
				return;
				
			var request:URLRequest = new URLRequest(Environment.serverUrl + "/clips.get_comments.xml?id=" + clip.id + "&page=" + page.toString() + "&per_page=" + perPage.toString());			
			var loader:URLLoader = new URLLoader();
			
			loader.addEventListener(Event.COMPLETE, onGetCommentsResult, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onGetCommentsError, false, 0, true);
			loader.load(request);
		}
		
		/**
		 * @private
		 */
		private function onGetCommentsResult(evt:Event):void{
			var loader:URLLoader = evt.currentTarget as URLLoader;
			var result:XML = XML(loader.data);
			loader.removeEventListener(Event.COMPLETE, onGetCommentsResult);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onGetCommentsError);

			numPages = Number(result.total_pages);
			numItems = Number(result.total_items);
			
			var page:Number = Number(result.page);
			if(page == 1)
				clip.comments = new Vector.<Comment>();
			
			numPagesLoaded += 1;
			
			// Parse comments
			var comments:Vector.<Comment> = new Vector.<Comment>();
			for each(var commentXml:XML in result.comments.children()){
				var comment:Comment = new Comment();
				comment.id = String(commentXml.id);
				comment.content = String(commentXml.content);
				comment.date = String(commentXml.date);
				
				comments.push(comment);
				clip.comments.push(comment);
			}
			
			var e:CommentEvent = new CommentEvent(CommentEvent.COMMENT_RETRIEVED);
			e.page = page;
			e.numPages = numPages;
			e.numItems = numItems;
			e.clip = clip;
			e.comments = comments;
			
			dispatchEvent(e);
		}
		
		/**
		 * @private
		 */
		private function onGetCommentsError(evt:IOErrorEvent):void{
			var loader:URLLoader = evt.currentTarget as URLLoader;
			loader.removeEventListener(Event.COMPLETE, onGetCommentsResult);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onGetCommentsError);
			
			trace("[CommentController] Error when reading annotations from server");
			trace(loader.data);
		}
		
	}
}
