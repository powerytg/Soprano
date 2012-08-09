package core.utils
{
	public class TimeUtil
	{
		/**
		 * @public
		 */
		public static const monthNames:Array = ["Oh My God", "January", "Feburary", "March", "April",
			"May", "June", "July", "August", "September",
			"October", "November", "December"];

		/**
		 * @public
		 */
		public static const shortMonthNames:Array = ["Oh My God", "Jan", "Feb", "Mar", "Apr",
			"May", "Jun", "Jul", "Aug", "Sep",
			"Oct", "Nov", "Dec"];

		/**
		 * @public
		 */
		public static const COMMON_YEAR_DAYS_IN_MONTH:Array = [null, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

		/**
		 * @public
		 */
		public static function formatTime(value:Number):String{
			var minutes:int = value / 60;
			var seconds:int = value % 60;
			
			var minString:String;
			if(minutes < 10)
				minString = "0" + minutes.toString();
			else
				minString = minutes.toString();
			
			var secString:String;
			if(seconds < 10)
				secString = "0" + seconds.toString();
			else
				secString = seconds.toString();
			
			return minString + ":" + secString;
		}
		
		/**
		 * @public
		 */
		public static function getMonthName(month:Number):String{
			return monthNames[month];
		}
		
		/**
		 * @public
		 */
		public static function getShortMonthName(month:Number):String{
			return shortMonthNames[month];
		}
		
		/**
		 * @public
		 */
		public static function isGregorianLeap(year:Number):Boolean{
			return ( year % 4 == 0 ) && ( ( year % 100 != 0 ) || ( year % 400 == 0 ) );
		}
		
		/**
		 * @public
		 */
		public static function numDaysInMonth(month:Number, year:Number):Number{
			if(month == 2 && isGregorianLeap(year))
				return 29;
			else
				return COMMON_YEAR_DAYS_IN_MONTH[month];
		}
		
		/**
		 * Constructor
		 */
		public function TimeUtil()
		{
		}
	}
}