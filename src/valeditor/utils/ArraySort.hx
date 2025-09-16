package valeditor.utils;
import valeditor.ValEditorClass;
import valeditor.ValEditorObject;
import valeditor.ValEditorTemplate;
import valeditor.ui.feathers.data.StringData;

/**
 * ...
 * @author Matse
 */
class ArraySort 
{

	//#if !SWC inline #end static public function alphabetical(a:String, b:String):Int
	inline static public function alphabetical(a:String, b:String):Int
	{
		a = a.toLowerCase();
		b = b.toLowerCase();
		if (a < b) return -1;
		if (a > b) return 1;
		return 0;
	}
	
	//#if !SWC inline #end static public function alphabetical_reverse(a:String, b:String):Int
	inline static public function alphabetical_reverse(a:String, b:String):Int
	{
		a = a.toLowerCase();
		b = b.toLowerCase();
		if (a < b) return 1;
		if (a > b) return -1;
		return 0;
	}
	
	//#if !SWC inline #end static public function float(a:Float, b:Float):Int
	inline static public function float(a:Float, b:Float):Int
	{
		if (a < b) return -1;
		if (a > b) return 1;
		return 0;
	}
	
	//#if !SWC inline #end static public function float_reverse(a:Float, b:Float):Int
	inline static public function float_reverse(a:Float, b:Float):Int
	{
		if (a < b) return 1;
		if (a > b) return -1;
		return 0;
	}
	
	//#if !SWC inline #end static public function integer(a:Int, b:Int):Int
	inline static public function integer(a:Int, b:Int):Int
	{
		if (a < b) return -1;
		if (a > b) return 1;
		return 0;
	}
	
	//#if !SWC inline #end static public function integer_reverse(a:Int, b:Int):Int
	inline static public function integer_reverse(a:Int, b:Int):Int
	{
		if (a < b) return 1;
		if (a > b) return -1;
		return 0;
	}
	
	//#if !SWC inline #end static public function object(a:ValEditorObject, b:ValEditorObject):Int
	inline static public function object(a:ValEditorObject, b:ValEditorObject):Int
	{
		var strA:String = a.className.toLowerCase();
		var strB:String = b.className.toLowerCase();
		if (strA < strB) return -1;
		if (strA > strB) return 1;
		strA = a.id.toLowerCase();
		strB = b.id.toLowerCase();
		if (strA < strB) return -1;
		if (strA > strB) return 1;
		return 0;
	}
	
	//#if !SWC inline #end static public function stringData(a:StringData, b:StringData):Int
	inline static public function stringData(a:StringData, b:StringData):Int
	{
		var strA:String = a.value.toLowerCase();
		var strB:String = b.value.toLowerCase();
		if (strA < strB) return -1;
		if (strA > strB) return 1;
		return 0;
	}
	
	//#if !SWC inline #end static public function template(a:ValEditorTemplate, b:ValEditorTemplate):Int
	inline static public function template(a:ValEditorTemplate, b:ValEditorTemplate):Int
	{
		var strA:String = a.clss.className.toLowerCase();
		var strB:String = b.clss.className.toLowerCase();
		if (strA < strB) return -1;
		if (strA > strB) return 1;
		strA = a.id.toLowerCase();
		strB = b.id.toLowerCase();
		if (strA < strB) return -1;
		if (strA > strB) return 1;
		return 0;
	}
	
	//#if !SWC inline #end static public function clss(a:ValEditorClass, b:ValEditorClass):Int
	inline static public function clss(a:ValEditorClass, b:ValEditorClass):Int
	{
		var strA:String = a.className.toLowerCase();
		var strB:String = b.className.toLowerCase();
		if (strA < strB) return -1;
		if (strA > strB) return 1;
		return 0;
	}
	
}