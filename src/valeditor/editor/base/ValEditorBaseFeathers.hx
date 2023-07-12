package valeditor.editor.base;

import feathers.controls.Application;
import feathers.controls.navigators.StackNavigator;
import feathers.style.Theme;
import openfl.display.StageScaleMode;
import valedit.ValEdit;
import valedit.asset.AssetLib;
import valedit.value.ExposedBitmap;
import valedit.value.ExposedBitmapData;
import valedit.value.ExposedBool;
import valedit.value.ExposedByteArray;
import valedit.value.ExposedColor;
import valedit.value.ExposedCombo;
import valedit.value.ExposedFloat;
import valedit.value.ExposedFloatDrag;
import valedit.value.ExposedFloatRange;
import valedit.value.ExposedFontName;
import valedit.value.ExposedFunction;
import valedit.value.ExposedGroup;
import valedit.value.ExposedInt;
import valedit.value.ExposedIntDrag;
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
import valedit.value.base.ExposedValue;
import valeditor.ui.feathers.FeathersFactories;
import valeditor.ui.feathers.theme.ValEditorTheme;

#if desktop
import valedit.value.ExposedFilePath;
import valedit.value.ExposedPath;
#end

#if starling
import valedit.value.starling.ExposedStarlingAtlas;
import valedit.value.starling.ExposedStarlingTexture;
#end

/**
 * ...
 * @author Matse
 */
class ValEditorBaseFeathers extends Application 
{
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
		
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.stageFocusRect = false;
		
		theme = new ValEditorTheme();
		Theme.setTheme(theme);
		
		AssetLib.init();
		AssetLib.load(assetsLoaded);
	}
	
	private function assetsLoaded():Void
	{
		registerExposedValuesFactories();
		registerExposedValuesUI();
		editorSetup();
		exposeData();
		initUI();
		ready();
	}
	
	private function editorSetup():Void
	{
		
	}
	
	private function exposeData():Void
	{
		
	}
	
	private function initUI():Void
	{
		screenNavigator = new StackNavigator();
		addChild(screenNavigator);
	}
	
	private function ready():Void
	{
		
	}
	
	private function registerExposedValuesFactories():Void
	{
		ExposedValue.registerFactory(ExposedBitmap, ExposedBitmap.fromPool);
		ExposedValue.registerFactory(ExposedBitmapData, ExposedBitmapData.fromPool);
		ExposedValue.registerFactory(ExposedBool, ExposedBool.fromPool);
		ExposedValue.registerFactory(ExposedByteArray, ExposedByteArray.fromPool);
		ExposedValue.registerFactory(ExposedColor, ExposedColor.fromPool);
		ExposedValue.registerFactory(ExposedCombo, ExposedCombo.fromPool);
		ExposedValue.registerFactory(ExposedFloat, ExposedFloat.fromPool);
		ExposedValue.registerFactory(ExposedFloatDrag, ExposedFloatDrag.fromPool);
		ExposedValue.registerFactory(ExposedFloatRange, ExposedFloatRange.fromPool);
		ExposedValue.registerFactory(ExposedFontName, ExposedFontName.fromPool);
		ExposedValue.registerFactory(ExposedFunction, ExposedFunction.fromPool);
		ExposedValue.registerFactory(ExposedGroup, ExposedGroup.fromPool);
		ExposedValue.registerFactory(ExposedInt, ExposedInt.fromPool);
		ExposedValue.registerFactory(ExposedIntDrag, ExposedIntDrag.fromPool);
		ExposedValue.registerFactory(ExposedIntRange, ExposedIntRange.fromPool);
		ExposedValue.registerFactory(ExposedName, ExposedName.fromPool);
		ExposedValue.registerFactory(ExposedNote, ExposedNote.fromPool);
		ExposedValue.registerFactory(ExposedObject, ExposedObject.fromPool);
		ExposedValue.registerFactory(ExposedObjectReference, ExposedObjectReference.fromPool);
		ExposedValue.registerFactory(ExposedSelect, ExposedSelect.fromPool);
		ExposedValue.registerFactory(ExposedSeparator, ExposedSeparator.fromPool);
		ExposedValue.registerFactory(ExposedSound, ExposedSound.fromPool);
		ExposedValue.registerFactory(ExposedSpacing, ExposedSpacing.fromPool);
		ExposedValue.registerFactory(ExposedString, ExposedString.fromPool);
		ExposedValue.registerFactory(ExposedText, ExposedText.fromPool);
		ExposedValue.registerFactory(ExposedTextAsset, ExposedTextAsset.fromPool);
		
		#if desktop
		ExposedValue.registerFactory(ExposedFilePath, ExposedFilePath.fromPool);
		ExposedValue.registerFactory(ExposedPath, ExposedPath.fromPool);
		#end
		
		#if starling
		ExposedValue.registerFactory(ExposedStarlingAtlas, ExposedStarlingAtlas.fromPool);
		ExposedValue.registerFactory(ExposedStarlingTexture, ExposedStarlingTexture.fromPool);
		#end
	}
	
	/**
	   
	**/
	private function registerExposedValuesUI():Void
	{
		ValEdit.registerUIClass(ExposedBitmap, FeathersFactories.exposedBitmap);
		ValEdit.registerUIClass(ExposedBitmapData, FeathersFactories.exposedBitmapData);
		ValEdit.registerUIClass(ExposedBool, FeathersFactories.exposedBool);
		ValEdit.registerUIClass(ExposedByteArray, FeathersFactories.exposedByteArray);
		ValEdit.registerUIClass(ExposedColor, FeathersFactories.exposedColor);
		ValEdit.registerUIClass(ExposedCombo, FeathersFactories.exposedCombo);
		ValEdit.registerUIClass(ExposedFloat, FeathersFactories.exposedFloat);
		ValEdit.registerUIClass(ExposedFloatDrag, FeathersFactories.exposedFloatDrag);
		ValEdit.registerUIClass(ExposedFloatRange, FeathersFactories.exposedFloatRange);
		ValEdit.registerUIClass(ExposedFontName, FeathersFactories.exposedFontName);
		ValEdit.registerUIClass(ExposedFunction, FeathersFactories.exposedFunction);
		ValEdit.registerUIClass(ExposedGroup, FeathersFactories.exposedGroup);
		ValEdit.registerUIClass(ExposedInt, FeathersFactories.exposedInt);
		ValEdit.registerUIClass(ExposedIntDrag, FeathersFactories.exposedIntDrag);
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
		
		#if desktop
		ValEdit.registerUIClass(ExposedFilePath, FeathersFactories.exposedFilePath);
		ValEdit.registerUIClass(ExposedPath, FeathersFactories.exposedPath);
		#end
		
		#if starling
		ValEdit.registerUIClass(ExposedStarlingAtlas, FeathersFactories.exposedStarlingAtlas);
		ValEdit.registerUIClass(ExposedStarlingTexture, FeathersFactories.exposedStarlingTexture);
		#end
	}
	
}