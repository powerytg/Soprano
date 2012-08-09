package core.env
{
	public class AdAvailability
	{
		/**
		 * @public
		 */
		public static const NONE:String = "none";

		/**
		 * @public
		 * 
		 * One single long ad, usually a pre-roll
		 */
		public static const LONG:String = "long";

		/**
		 * @public
		 * 
		 * Multiple shorter ads, could be pre-roll or mid-roll
		 */
		public static const NORMAL:String = "normal";

		/**
		 * Constructor
		 */
		public function AdAvailability()
		{
		}
	}
}