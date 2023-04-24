package editor.base;

import valedit.asset.AssetLib;
import feathers.controls.Application;
import feathers.controls.navigators.StackItem;
import feathers.controls.navigators.StackNavigator;
import feathers.style.Theme;
import openfl.display.StageScaleMode;
import valedit.data.openfl.display.DisplayData;
import valedit.data.openfl.geom.GeomData;
import openfl.display.Sprite;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.geom.Transform;
import ui.feathers.FeathersFactories;
import ui.feathers.theme.ValEditorTheme;
import ui.feathers.view.EditView;
import valedit.value.ExposedBitmap;
import valedit.value.ExposedByteArray;
import valedit.value.ExposedColorReadOnly;
import valedit.value.ExposedFunction;
import valedit.value.ExposedGroup;
import valedit.ValEdit;
import valedit.value.ExposedBool;
import valedit.value.ExposedColor;
import valedit.value.ExposedFloat;
import valedit.value.ExposedFloatRange;
import valedit.value.ExposedInt;
import valedit.value.ExposedIntRange;
import valedit.value.ExposedName;
import valedit.value.ExposedNote;
import valedit.value.ExposedObject;
import valedit.value.ExposedSelect;
import valedit.value.ExposedSeparator;
import valedit.value.ExposedSound;
import valedit.value.ExposedSpacing;
import valedit.value.ExposedStarlingTexture;
import valedit.value.ExposedString;
import valedit.value.ExposedText;
import valedit.value.ExposedTextAsset;

/**
 * ...
 * @author Matse
 */
class ValEditorBaseFeathers extends Application 
{
	public var scene(default, null):Sprite;
	public var screenNavigator(default, null):StackNavigator;
	public var theme(default, null):ValEditorTheme;
	public var editView(default, null):EditView;
	
	/**
	   
	**/
	public function new() 
	{
		super();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		AssetLib.init();
		
		initUI();
		
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.stageFocusRect = false;
		
		scene = new Sprite();
		addChild(scene);
		
		theme = new ValEditorTheme();
		Theme.setTheme(theme);
		
		AssetLib.load(ready);
	}
	
	private function ready():Void
	{
		var item:StackItem;
		
		screenNavigator = new StackNavigator();
		addChild(screenNavigator);
		
		editView = new EditView();
		editView.initializeNow();
		ValEdit.uiContainerDefault = editView.valEditContainer;
		
		item = StackItem.withDisplayObject(EditView.ID, editView);
		screenNavigator.addItem(item);
		
		screenNavigator.pushItem(EditView.ID);
	}
	
	/**
	   
	**/
	private function initUI():Void
	{
		ValEdit.registerUIClass(ExposedBitmap, FeathersFactories.exposedBitmap);
		ValEdit.registerUIClass(ExposedBool, FeathersFactories.exposedBool);
		ValEdit.registerUIClass(ExposedByteArray, FeathersFactories.exposedByteArray);
		ValEdit.registerUIClass(ExposedColor, FeathersFactories.exposedColor);
		ValEdit.registerUIClass(ExposedColorReadOnly, FeathersFactories.exposedColorReadOnly);
		ValEdit.registerUIClass(ExposedFloat, FeathersFactories.exposedFloat);
		ValEdit.registerUIClass(ExposedFloatRange, FeathersFactories.exposedFloatRange);
		ValEdit.registerUIClass(ExposedFunction, FeathersFactories.exposedFunction);
		ValEdit.registerUIClass(ExposedGroup, FeathersFactories.exposedGroup);
		ValEdit.registerUIClass(ExposedInt, FeathersFactories.exposedInt);
		ValEdit.registerUIClass(ExposedIntRange, FeathersFactories.exposedIntRange);
		ValEdit.registerUIClass(ExposedName, FeathersFactories.exposedName);
		ValEdit.registerUIClass(ExposedNote, FeathersFactories.exposedNote);
		ValEdit.registerUIClass(ExposedObject, FeathersFactories.exposedObject);
		ValEdit.registerUIClass(ExposedSelect, FeathersFactories.exposedSelect);
		ValEdit.registerUIClass(ExposedSeparator, FeathersFactories.exposedSeparator);
		ValEdit.registerUIClass(ExposedSound, FeathersFactories.exposedSound);
		ValEdit.registerUIClass(ExposedSpacing, FeathersFactories.exposedSpacing);
		ValEdit.registerUIClass(ExposedString, FeathersFactories.exposedString);
		ValEdit.registerUIClass(ExposedText, FeathersFactories.exposedText);
		ValEdit.registerUIClass(ExposedTextAsset, FeathersFactories.exposedTextAsset);
		
		#if starling
		ValEdit.registerUIClass(ExposedStarlingTexture, FeathersFactories.exposedStarlingTexture);
		#end
	}
	
}