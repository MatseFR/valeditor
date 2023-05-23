package ui.feathers;
import ui.feathers.controls.value.BitmapUI;
import ui.feathers.controls.value.BoolUI;
import ui.feathers.controls.value.ByteArrayUI;
import ui.feathers.controls.value.ColorReadOnlyUI;
import ui.feathers.controls.value.ColorUI;
import ui.feathers.controls.value.ComboUI;
import ui.feathers.controls.value.FloatRangeUI;
import ui.feathers.controls.value.FloatUI;
import ui.feathers.controls.value.FontNameUI;
import ui.feathers.controls.value.FunctionUI;
import ui.feathers.controls.value.GroupUI;
import ui.feathers.controls.value.IntRangeUI;
import ui.feathers.controls.value.IntUI;
import ui.feathers.controls.value.NameUI;
import ui.feathers.controls.value.ObjectReferenceUI;
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
	
	static public function exposedBitmap():IValueUI
	{
		return new BitmapUI();
	}
	
	static public function exposedBitmapData():IValueUI
	{
		return new BitmapUI();
	}
	
	static public function exposedBool():IValueUI
	{
		return new BoolUI();
	}
	
	static public function exposedByteArray():IValueUI
	{
		return new ByteArrayUI();
	}
	
	static public function exposedColor():IValueUI
	{
		return new ColorUI();
	}
	
	static public function exposedColorReadOnly():IValueUI
	{
		return new ColorReadOnlyUI();
	}
	
	static public function exposedCombo():IValueUI
	{
		return new ComboUI();
	}
	
	static public function exposedFloat():IValueUI
	{
		return new FloatUI();
	}
	
	static public function exposedFloatRange():IValueUI
	{
		return new FloatRangeUI();
	}
	
	static public function exposedFontName():IValueUI
	{
		return new FontNameUI();
	}
	
	static public function exposedFunction():IValueUI
	{
		return new FunctionUI();
	}
	
	static public function exposedGroup():IValueUI
	{
		return new GroupUI();
	}
	
	static public function exposedInt():IValueUI
	{
		return new IntUI();
	}
	
	static public function exposedIntRange():IValueUI
	{
		return new IntRangeUI();
	}
	
	static public function exposedName():IValueUI
	{
		return new NameUI();
	}
	
	static public function exposedNote():IValueUI
	{
		return new NoteUI();
	}
	
	static public function exposedObject():IValueUI
	{
		return new ObjectUI();
	}
	
	static public function exposedObjectReference():IValueUI
	{
		return new ObjectReferenceUI();
	}
	
	static public function exposedSelect():IValueUI
	{
		return new SelectUI();
	}
	
	static public function exposedSeparator():IValueUI
	{
		return new SeparatorUI();
	}
	
	static public function exposedSound():IValueUI
	{
		return new SoundUI();
	}
	
	static public function exposedSpacing():IValueUI
	{
		return new SpacingUI();
	}
	
	static public function exposedString():IValueUI
	{
		return new StringUI();
	}
	
	static public function exposedText():IValueUI
	{
		return new TextUI();
	}
	
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