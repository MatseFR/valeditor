package valeditor.editor.base;

import feathers.controls.Application;
import feathers.controls.navigators.StackItem;
import feathers.controls.navigators.StackNavigator;
import feathers.style.Theme;
import openfl.display.Sprite;
import openfl.display.StageScaleMode;
import valeditor.ui.feathers.FeathersFactories;
import valeditor.ui.feathers.theme.ValEditorTheme;
import valeditor.ui.feathers.view.EditView;
import valedit.ValEdit;
import valedit.asset.AssetLib;
import valedit.value.ExposedBitmap;
import valedit.value.ExposedBitmapData;
import valedit.value.ExposedBool;
import valedit.value.ExposedByteArray;
import valedit.value.ExposedColor;
import valedit.value.ExposedColorReadOnly;
import valedit.value.ExposedCombo;
import valedit.value.ExposedFloat;
import valedit.value.ExposedFloatRange;
import valedit.value.ExposedFontName;
import valedit.value.ExposedFunction;
import valedit.value.ExposedGroup;
import valedit.value.ExposedInt;
import valedit.value.ExposedIntRange;
import valedit.value.ExposedName;
import valedit.value.ExposedNote;
import valedit.value.ExposedObject;
import valedit.value.ExposedObjectReference;
import valedit.value.ExposedSelect;
import valedit.value.ExposedSeparator;
import valedit.value.ExposedSound;
import valedit.value.ExposedSpacing;
import valedit.value.ExposedString;
import valedit.value.ExposedText;
import valedit.value.ExposedTextAsset;

#if starling
import starling.core.Starling;
import valedit.value.starling.ExposedStarlingAtlas;
import valedit.value.starling.ExposedStarlingTexture;
#end

/**
 * ...
 * @author Matse
 */
class ValEditorBaseFeathers extends Application 
{
	public var scene(default, null):Sprite;
	#if starling
	public var starlingScene(default, null):starling.display.Sprite;
	#end
	public var screenNavigator(default, null):StackNavigator;
	public var theme(default, null):ValEditorTheme;
	
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
		
		#if starling
		starlingScene = new starling.display.Sprite();
		Starling.current.stage.addChild(starlingScene);
		#end
		
		theme = new ValEditorTheme();
		Theme.setTheme(theme);
		
		AssetLib.load(ready);
	}
	
	private function ready():Void
	{
		screenNavigator = new StackNavigator();
		addChild(screenNavigator);
	}
	
	/**
	   
	**/
	private function initUI():Void
	{
		ValEdit.registerUIClass(ExposedBitmap, FeathersFactories.exposedBitmap);
		ValEdit.registerUIClass(ExposedBitmapData, FeathersFactories.exposedBitmapData);
		ValEdit.registerUIClass(ExposedBool, FeathersFactories.exposedBool);
		ValEdit.registerUIClass(ExposedByteArray, FeathersFactories.exposedByteArray);
		ValEdit.registerUIClass(ExposedColor, FeathersFactories.exposedColor);
		ValEdit.registerUIClass(ExposedColorReadOnly, FeathersFactories.exposedColorReadOnly);
		ValEdit.registerUIClass(ExposedCombo, FeathersFactories.exposedCombo);
		ValEdit.registerUIClass(ExposedFloat, FeathersFactories.exposedFloat);
		ValEdit.registerUIClass(ExposedFloatRange, FeathersFactories.exposedFloatRange);
		ValEdit.registerUIClass(ExposedFontName, FeathersFactories.exposedFontName);
		ValEdit.registerUIClass(ExposedFunction, FeathersFactories.exposedFunction);
		ValEdit.registerUIClass(ExposedGroup, FeathersFactories.exposedGroup);
		ValEdit.registerUIClass(ExposedInt, FeathersFactories.exposedInt);
		ValEdit.registerUIClass(ExposedIntRange, FeathersFactories.exposedIntRange);
		ValEdit.registerUIClass(ExposedName, FeathersFactories.exposedName);
		ValEdit.registerUIClass(ExposedNote, FeathersFactories.exposedNote);
		ValEdit.registerUIClass(ExposedObject, FeathersFactories.exposedObject);
		ValEdit.registerUIClass(ExposedObjectReference, FeathersFactories.exposedObjectReference);
		ValEdit.registerUIClass(ExposedSelect, FeathersFactories.exposedSelect);
		ValEdit.registerUIClass(ExposedSeparator, FeathersFactories.exposedSeparator);
		ValEdit.registerUIClass(ExposedSound, FeathersFactories.exposedSound);
		ValEdit.registerUIClass(ExposedSpacing, FeathersFactories.exposedSpacing);
		ValEdit.registerUIClass(ExposedString, FeathersFactories.exposedString);
		ValEdit.registerUIClass(ExposedText, FeathersFactories.exposedText);
		ValEdit.registerUIClass(ExposedTextAsset, FeathersFactories.exposedTextAsset);
		
		#if starling
		ValEdit.registerUIClass(ExposedStarlingAtlas, FeathersFactories.exposedStarlingAtlas);
		ValEdit.registerUIClass(ExposedStarlingTexture, FeathersFactories.exposedStarlingTexture);
		#end
	}
	
}