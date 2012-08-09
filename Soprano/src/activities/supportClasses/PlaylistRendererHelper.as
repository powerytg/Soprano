package activities.supportClasses
{
	public class PlaylistRendererHelper
	{

		/**
		 * @public
		 */
		[Embed(source="../images/OneItemBackground.png")]
		public static var oneItemFace:Class;

		/**
		 * @public
		 */
		[Embed(source="../images/ThreeItemsBackground.png")]
		public static var threeItemsFace:Class;

		/**
		 * @public
		 */
		[Embed(source="../images/TwoItemsBackground.png")]
		public static var twoItemsFace:Class;

		/**
		 * @public
		 */
		[Embed(source="../images/MoreItemsBackground.png")]
		public static var moreItemsFace:Class;

		/**
		 * @public
		 */
		public static function getBackground(numClips:Number):Class{
			if(numClips < 2)
				return oneItemFace;
			else if(numClips == 2)
				return twoItemsFace;
			else if(numClips == 3)
				return threeItemsFace;
			
			return moreItemsFace;
		}
		
		/**
		 * @public
		 */
		public static function getColor(numClips:Number):Number{
			if(numClips < 2)
				return 0;
			else if(numClips == 2)
				return 0xf893b6;
			else if(numClips == 3)
				return 0x9c88e6;
			
			return 0xf8c593;
		}
		
		/**
		 * Constructor
		 */
		public function PlaylistRendererHelper()
		{
		}
	}
}