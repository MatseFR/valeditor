package ui.feathers;
import ui.feathers.controls.value.BitmapUI;
import ui.feathers.controls.value.BoolUI;
import ui.feathers.controls.value.ByteArrayUI;
import ui.feathers.controls.value.ColorReadOnlyUI;
import ui.feathers.controls.value.ColorUI;
import ui.feathers.controls.value.FloatRangeUI;
import ui.feathers.controls.value.FloatUI;
import ui.feathers.controls.value.FunctionUI;
import ui.feathers.controls.value.GroupUI;
import ui.feathers.controls.value.IntRangeUI;
import ui.feathers.controls.value.IntUI;
import ui.feathers.controls.value.NameUI;
import ui.feathers.controls.value.ObjectUI;
import ui.feathers.controls.value.SelectUI;
import ui.feathers.controls.value.SeparatorUI;
import ui.feathers.controls.value.SoundUI;
import ui.feathers.controls.value.SpacingUI;
#if starling
import ui.feathers.controls.value.starling.StarlingTextureUI;
#end
import ui.feathers.controls.value.StringUI;
import ui.feathers.controls.value.NoteUI;
import ui.feathers.controls.value.TextAssetUI;
import ui.feathers.controls.value.TextUI;
import ui.feathers.controls.value.starling.StarlingAtlasUI;
import valedit.ui.IValueUI;

/**
 * ...
 * @author Matse
 */
class FeathersFactories 
{
	/**
	   
	   @return
	**/
	static public function exposedBitmap():IValueUI
	{
		return new BitmapUI();
	}
	
	/**
	   
	   @return
	**/
	static public function exposedBitmapData():IValueUI
	{
		return new BitmapUI();
	}
	
	/**
	   
	   @return
	**/
	static public function exposedBool():IValueUI
	{
		return new BoolUI();
	}
	
	/**
	   
	   @return
	**/
	static public function exposedByteArray():IValueUI
	{
		return new ByteArrayUI();
	}
	
	/**
	   
	   @return
	**/
	static public function exposedColor():IValueUI
	{
		return new ColorUI();
	}
	
	/**
	   
	   @return
	**/
	static public function exposedColorReadOnly():IValueUI
	{
		return new ColorReadOnlyUI();
	}
	
	/**
	   
	   @return
	**/
	static public function exposedFloat():IValueUI
	{
		return new FloatUI();
	}
	
	/**
	   
	   @return
	**/
	static public function exposedFloatRange():IValueUI
	{
		return new FloatRangeUI();
	}
	
	/**
	   
	   @return
	**/
	static public function exposedFunction():IValueUI
	{
		return new FunctionUI();
	}
	
	/**
	   
	   @return
	**/
	static public function exposedGroup():IValueUI
	{
		return new GroupUI();
	}
	
	/**
	   
	   @return
	**/
	static public function exposedInt():IValueUI
	{
		return new IntUI();
	}
	
	/**
	   
	   @return
	**/
	static public function exposedIntRange():IValueUI
	{
		return new IntRangeUI();
	}
	
	/**
	   
	   @return
	**/
	static public function exposedName():IValueUI
	{
		return new NameUI();
	}
	
	/**
	   
	   @return
	**/
	static public function exposedNote():IValueUI
	{
		return new NoteUI();
	}
	
	/**
	   
	   @return
	**/
	static public function exposedObject():IValueUI
	{
		return new ObjectUI();
	}
	
	/**
	   
	   @return
	**/
	static public function exposedSelect():IValueUI
	{
		return new SelectUI();
	}
	
	/**
	   
	   @return
	**/
	static public function exposedSeparator():IValueUI
	{
		return new SeparatorUI();
	}
	
	/**
	   
	   @return
	**/
	static public function exposedSound():IValueUI
	{
		return new SoundUI();
	}
	
	/**
	   
	   @return
	**/
	static public function exposedSpacing():IValueUI
	{
		return new SpacingUI();
	}
	
	/**
	   
	   @return
	**/
	static public function exposedString():IValueUI
	{
		return new StringUI();
	}
	
	/**
	   
	   @return
	**/
	static public function exposedText():IValueUI
	{
		return new TextUI();
	}
	
	/**
	   
	   @return
	**/
	static public function exposedTextAsset():IValueUI
	{
		return new TextAssetUI();
	}
	
	#if starling
	static public function exposedStarlingAtlas():IValueUI
	{
		return new StarlingAtlasUI();
	}
	
	static public function exposedStarlingTexture():IValueUI
	{
		return new StarlingTextureUI();
	}
	#end
	
}