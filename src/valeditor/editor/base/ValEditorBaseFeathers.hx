package valeditor.editor.base;

import feathers.controls.Application;
import feathers.controls.navigators.StackNavigator;
import feathers.style.Theme;
import openfl.display.StageScaleMode;
import valedit.ExposedCollection;
import valedit.data.feathers.themes.SimpleThemeData;
import valedit.data.valeditor.SettingsData;
import valedit.value.ExposedBitmap;
import valedit.value.ExposedBitmapData;
import valedit.value.ExposedBool;
import valedit.value.ExposedByteArray;
import valedit.value.ExposedColor;
import valedit.value.ExposedFloat;
import valedit.value.ExposedFloatDrag;
import valedit.value.ExposedFloatRange;
import valedit.value.ExposedFontName;
import valedit.value.ExposedFunction;
import valedit.value.ExposedFunctionExternal;
import valedit.value.ExposedGroup;
import valedit.value.ExposedInt;
import valedit.value.ExposedIntDrag;
import valedit.value.ExposedIntRange;
import valedit.value.ExposedName;
import valedit.value.ExposedNote;
import valedit.value.ExposedObject;
import valedit.value.ExposedObjectReference;
import valedit.value.ExposedSelect;
import valedit.value.ExposedSelectCombo;
import valedit.value.ExposedSeparator;
import valedit.value.ExposedSound;
import valedit.value.ExposedSpacing;
import valedit.value.ExposedString;
import valedit.value.ExposedText;
import valedit.value.ExposedTextAsset;
import valedit.value.base.ExposedValue;
import valeditor.editor.settings.EditorSettings;
import valeditor.ui.feathers.FeathersFactories;
import valeditor.ui.feathers.theme.ValEditorTheme;
import valeditor.utils.file.FileUtil;

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
	
	/**
	   
	**/
	public function new() 
	{
		super();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		this.stage.scaleMode = StageScaleMode.NO_SCALE;
		this.stage.stageFocusRect = false;
		
		this.stage.showDefaultContextMenu = false;
		
		ValEditor.theme = new ValEditorTheme();
		Theme.setTheme(ValEditor.theme);
		
		ValEditor.init(assetsLoaded);
	}
	
	private function assetsLoaded():Void
	{
		registerExposedValuesFactories();
		registerExposedValuesUI();
		editorSetup();
		exposeData();
		loadEditorSettings();
		initUI();
		ready();
	}
	
	private function editorSetup():Void
	{
		
	}
	
	private function exposeData():Void
	{
		// UI Theme
		ValEditor.registerClassSimple(ValEditorTheme, false, SimpleThemeData.exposeSimpleTheme());
		
		// Editor Settings
		ValEditor.registerClassSimple(EditorSettings, false, SettingsData.exposeEditorSettings());
	}
	
	private function loadEditorSettings():Void
	{
		var collection:ExposedCollection;
		
		// store default values for easy restoration
		collection = ValEditor.getCollectionForObject(ValEditor.theme);
		collection.readValuesFromObject(ValEditor.theme, false);
		ValEditor.themeDefaultValues = collection;
		
		collection = ValEditor.getCollectionForObject(ValEditor.theme);
		collection.readValuesFromObject(ValEditor.theme, false);
		ValEditor.editorSettings.themeCustomValues = collection;
		
		FileUtil.loadEditorSettings();
		
		ValEditor.editorSettings.apply();
	}
	
	private function initUI():Void
	{
		this.screenNavigator = new StackNavigator();
		addChild(this.screenNavigator);
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
		ExposedValue.registerFactory(ExposedFloat, ExposedFloat.fromPool);
		ExposedValue.registerFactory(ExposedFloatDrag, ExposedFloatDrag.fromPool);
		ExposedValue.registerFactory(ExposedFloatRange, ExposedFloatRange.fromPool);
		ExposedValue.registerFactory(ExposedFontName, ExposedFontName.fromPool);
		ExposedValue.registerFactory(ExposedFunction, ExposedFunction.fromPool);
		ExposedValue.registerFactory(ExposedFunctionExternal, ExposedFunctionExternal.fromPool);
		ExposedValue.registerFactory(ExposedGroup, ExposedGroup.fromPool);
		ExposedValue.registerFactory(ExposedInt, ExposedInt.fromPool);
		ExposedValue.registerFactory(ExposedIntDrag, ExposedIntDrag.fromPool);
		ExposedValue.registerFactory(ExposedIntRange, ExposedIntRange.fromPool);
		ExposedValue.registerFactory(ExposedName, ExposedName.fromPool);
		ExposedValue.registerFactory(ExposedNote, ExposedNote.fromPool);
		ExposedValue.registerFactory(ExposedObject, ExposedObject.fromPool);
		ExposedValue.registerFactory(ExposedObjectReference, ExposedObjectReference.fromPool);
		ExposedValue.registerFactory(ExposedSelect, ExposedSelect.fromPool);
		ExposedValue.registerFactory(ExposedSelectCombo, ExposedSelectCombo.fromPool);
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
		ValEditor.registerUIClass(ExposedBitmap, FeathersFactories.exposedBitmap);
		ValEditor.registerUIClass(ExposedBitmapData, FeathersFactories.exposedBitmapData);
		ValEditor.registerUIClass(ExposedBool, FeathersFactories.exposedBool);
		ValEditor.registerUIClass(ExposedByteArray, FeathersFactories.exposedByteArray);
		ValEditor.registerUIClass(ExposedColor, FeathersFactories.exposedColor);
		ValEditor.registerUIClass(ExposedFloat, FeathersFactories.exposedFloat);
		ValEditor.registerUIClass(ExposedFloatDrag, FeathersFactories.exposedFloatDrag);
		ValEditor.registerUIClass(ExposedFloatRange, FeathersFactories.exposedFloatRange);
		ValEditor.registerUIClass(ExposedFontName, FeathersFactories.exposedFontName);
		ValEditor.registerUIClass(ExposedFunction, FeathersFactories.exposedFunction);
		ValEditor.registerUIClass(ExposedFunctionExternal, FeathersFactories.exposedFunctionExternal);
		ValEditor.registerUIClass(ExposedGroup, FeathersFactories.exposedGroup);
		ValEditor.registerUIClass(ExposedInt, FeathersFactories.exposedInt);
		ValEditor.registerUIClass(ExposedIntDrag, FeathersFactories.exposedIntDrag);
		ValEditor.registerUIClass(ExposedIntRange, FeathersFactories.exposedIntRange);
		ValEditor.registerUIClass(ExposedName, FeathersFactories.exposedName);
		ValEditor.registerUIClass(ExposedNote, FeathersFactories.exposedNote);
		ValEditor.registerUIClass(ExposedObject, FeathersFactories.exposedObject);
		ValEditor.registerUIClass(ExposedObjectReference, FeathersFactories.exposedObjectReference);
		ValEditor.registerUIClass(ExposedSelect, FeathersFactories.exposedSelect);
		ValEditor.registerUIClass(ExposedSelectCombo, FeathersFactories.exposedSelectCombo);
		ValEditor.registerUIClass(ExposedSeparator, FeathersFactories.exposedSeparator);
		ValEditor.registerUIClass(ExposedSound, FeathersFactories.exposedSound);
		ValEditor.registerUIClass(ExposedSpacing, FeathersFactories.exposedSpacing);
		ValEditor.registerUIClass(ExposedString, FeathersFactories.exposedString);
		ValEditor.registerUIClass(ExposedText, FeathersFactories.exposedText);
		ValEditor.registerUIClass(ExposedTextAsset, FeathersFactories.exposedTextAsset);
		
		#if desktop
		ValEditor.registerUIClass(ExposedFilePath, FeathersFactories.exposedFilePath);
		ValEditor.registerUIClass(ExposedPath, FeathersFactories.exposedPath);
		#end
		
		#if starling
		ValEditor.registerUIClass(ExposedStarlingAtlas, FeathersFactories.exposedStarlingAtlas);
		ValEditor.registerUIClass(ExposedStarlingTexture, FeathersFactories.exposedStarlingTexture);
		#end
	}
	
}