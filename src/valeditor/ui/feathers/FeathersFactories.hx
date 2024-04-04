package valeditor.ui.feathers;
import valedit.ui.IValueUI;
import valedit.ui.UICollection;
import valeditor.ui.feathers.controls.value.BitmapUI;
import valeditor.ui.feathers.controls.value.BoolUI;
import valeditor.ui.feathers.controls.value.ByteArrayUI;
import valeditor.ui.feathers.controls.value.ColorUI;
import valeditor.ui.feathers.controls.value.FloatDraggerUI;
import valeditor.ui.feathers.controls.value.FloatRangeUI;
import valeditor.ui.feathers.controls.value.FloatUI;
import valeditor.ui.feathers.controls.value.FontNameUI;
import valeditor.ui.feathers.controls.value.FunctionUI;
import valeditor.ui.feathers.controls.value.GroupUI;
import valeditor.ui.feathers.controls.value.IntDraggerUI;
import valeditor.ui.feathers.controls.value.IntRangeUI;
import valeditor.ui.feathers.controls.value.IntUI;
import valeditor.ui.feathers.controls.value.NameUI;
import valeditor.ui.feathers.controls.value.NoteUI;
import valeditor.ui.feathers.controls.value.ObjectReferenceUI;
import valeditor.ui.feathers.controls.value.ObjectUI;
import valeditor.ui.feathers.controls.value.SelectComboUI;
import valeditor.ui.feathers.controls.value.SelectUI;
import valeditor.ui.feathers.controls.value.SeparatorUI;
import valeditor.ui.feathers.controls.value.SoundUI;
import valeditor.ui.feathers.controls.value.SpacingUI;
import valeditor.ui.feathers.controls.value.StringUI;
import valeditor.ui.feathers.controls.value.TextAssetUI;
import valeditor.ui.feathers.controls.value.TextUI;

#if desktop
import valeditor.ui.feathers.controls.value.FilePathUI;
import valeditor.ui.feathers.controls.value.PathUI;
#end

#if starling
import valeditor.ui.feathers.controls.value.starling.StarlingAtlasUI;
import valeditor.ui.feathers.controls.value.starling.StarlingTextureUI;
#end

/**
 * ...
 * @author Matse
 */
class FeathersFactories 
{
	static public function disposePools():Void
	{
		UICollection.disposePool();
		
		BitmapUI.disposePool();
		BoolUI.disposePool();
		ByteArrayUI.disposePool();
		ColorUI.disposePool();
		#if desktop
		FilePathUI.disposePool();
		#end
		FloatUI.disposePool();
		FloatDraggerUI.disposePool();
		FloatRangeUI.disposePool();
		FontNameUI.disposePool();
		FunctionUI.disposePool();
		GroupUI.disposePool();
		IntUI.disposePool();
		IntDraggerUI.disposePool();
		IntRangeUI.disposePool();
		NameUI.disposePool();
		NoteUI.disposePool();
		ObjectUI.disposePool();
		ObjectReferenceUI.disposePool();
		#if desktop
		PathUI.disposePool();
		#end
		SelectComboUI.disposePool();
		SelectUI.disposePool();
		SeparatorUI.disposePool();
		SoundUI.disposePool();
		SpacingUI.disposePool();
		StringUI.disposePool();
		TextUI.disposePool();
		TextAssetUI.disposePool();
		
		#if starling
		StarlingAtlasUI.disposePool();
		StarlingTextureUI.disposePool();
		#end
	}
	
	static public function exposedBitmap():IValueUI
	{
		return BitmapUI.fromPool();
	}
	
	static public function exposedBitmapData():IValueUI
	{
		return BitmapUI.fromPool();
	}
	
	static public function exposedBool():IValueUI
	{
		return BoolUI.fromPool();
	}
	
	static public function exposedByteArray():IValueUI
	{
		return ByteArrayUI.fromPool();
	}
	
	static public function exposedColor():IValueUI
	{
		return ColorUI.fromPool();
	}
	
	#if desktop
	static public function exposedFilePath():IValueUI
	{
		return FilePathUI.fromPool();
	}
	#end
	
	static public function exposedFloat():IValueUI
	{
		return FloatUI.fromPool();
	}
	
	static public function exposedFloatDrag():IValueUI
	{
		return FloatDraggerUI.fromPool();
	}
	
	static public function exposedFloatRange():IValueUI
	{
		return FloatRangeUI.fromPool();
	}
	
	static public function exposedFontName():IValueUI
	{
		return FontNameUI.fromPool();
	}
	
	static public function exposedFunction():IValueUI
	{
		return FunctionUI.fromPool();
	}
	
	static public function exposedFunctionExternal():IValueUI
	{
		return FunctionUI.fromPool();
	}
	
	static public function exposedGroup():IValueUI
	{
		return GroupUI.fromPool();
	}
	
	static public function exposedInt():IValueUI
	{
		return IntUI.fromPool();
	}
	
	static public function exposedIntDrag():IValueUI
	{
		return IntDraggerUI.fromPool();
	}
	
	static public function exposedIntRange():IValueUI
	{
		return IntRangeUI.fromPool();
	}
	
	static public function exposedName():IValueUI
	{
		return NameUI.fromPool();
	}
	
	static public function exposedNote():IValueUI
	{
		return NoteUI.fromPool();
	}
	
	static public function exposedObject():IValueUI
	{
		return ObjectUI.fromPool();
	}
	
	static public function exposedObjectReference():IValueUI
	{
		return ObjectReferenceUI.fromPool();
	}
	
	#if desktop
	static public function exposedPath():IValueUI
	{
		return PathUI.fromPool();
	}
	#end
	
	static public function exposedSelect():IValueUI
	{
		return SelectUI.fromPool();
	}
	
	static public function exposedSelectCombo():IValueUI
	{
		return SelectComboUI.fromPool();
	}
	
	static public function exposedSeparator():IValueUI
	{
		return SeparatorUI.fromPool();
	}
	
	static public function exposedSound():IValueUI
	{
		return SoundUI.fromPool();
	}
	
	static public function exposedSpacing():IValueUI
	{
		return SpacingUI.fromPool();
	}
	
	static public function exposedString():IValueUI
	{
		return StringUI.fromPool();
	}
	
	static public function exposedText():IValueUI
	{
		return TextUI.fromPool();
	}
	
	static public function exposedTextAsset():IValueUI
	{
		return TextAssetUI.fromPool();
	}
	
	#if starling
	static public function exposedStarlingAtlas():IValueUI
	{
		return StarlingAtlasUI.fromPool();
	}
	
	static public function exposedStarlingTexture():IValueUI
	{
		return StarlingTextureUI.fromPool();
	}
	#end
	
}