package valeditor.editor.settings;
import valedit.ExposedCollection;
import valeditor.ValEditorClass;
import valeditor.editor.visibility.ClassVisibilitiesCollection;
import valeditor.editor.visibility.ClassVisibilityCollection;

/**
 * ...
 * @author Matse
 */
class EditorSettings 
{
	#if (desktop || air)
	public var autoSave:Bool = true;
	public var autoSaveInterval:Int = 5;
	#end
	public var customClassVisibilities:ClassVisibilitiesCollection = new ClassVisibilitiesCollection();
	public var releaseUIFocusOnValidation:Bool = true;
	public var themeCustomValues:ExposedCollection;
	public var uiDarkMode:Bool = false;
	public var undoLevels:Int = 300;
	
	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		#if (desktop || air)
		this.autoSave = true;
		this.autoSaveInterval = 5;
		#end
		this.customClassVisibilities.clear();
		this.releaseUIFocusOnValidation = true;
		if (this.themeCustomValues != null)
		{
			this.themeCustomValues.pool();
			this.themeCustomValues = null;
		}
		this.uiDarkMode = false;
		this.undoLevels = 300;
	}
	
	public function apply():Void
	{
		this.themeCustomValues.applyToObject(ValEditor.theme);
		ValEditor.theme.darkMode = this.uiDarkMode;
		ValEditor.actionStack.undoLevels = this.undoLevels;
		
		var collection:ClassVisibilityCollection;
		for (clss in ValEditor.classCollection)
		{
			collection = this.customClassVisibilities.get(clss.className);
			clss.visibilityCollectionSettings = collection;
		}
	}
	
	public function clone(?toSettings:EditorSettings):EditorSettings
	{
		if (toSettings == null) toSettings = new EditorSettings();
		
		#if (desktop || air)
		toSettings.autoSave = this.autoSave;
		toSettings.autoSaveInterval = this.autoSaveInterval;
		#end
		
		this.customClassVisibilities.clone(toSettings.customClassVisibilities);
		
		toSettings.releaseUIFocusOnValidation = this.releaseUIFocusOnValidation;
		if (toSettings.themeCustomValues == null)
		{
			toSettings.themeCustomValues = this.themeCustomValues.clone(true);
		}
		else
		{
			toSettings.themeCustomValues.copyValuesFrom(this.themeCustomValues);
		}
		toSettings.uiDarkMode = this.uiDarkMode;
		toSettings.undoLevels = this.undoLevels;
		
		return toSettings;
	}
	
	public function fromJSON(json:Dynamic):Void
	{
		#if (desktop || air)
		this.autoSave = json.autoSave;
		this.autoSaveInterval = json.autoSaveInterval;
		#end
		
		if (json.customClassVisibilities != null)
		{
			this.customClassVisibilities.fromJSON(json.customClassVisibilities);
		}
		
		this.releaseUIFocusOnValidation = json.releaseUIFocusOnValidation;
		if (json.themeCustomValues != null)
		{
			this.themeCustomValues.fromJSONSave(json.themeCustomValues);
		}
		this.uiDarkMode = json.uiDarkMode;
		this.undoLevels = json.undoLevels;
	}
	
	public function toJSON(json:Dynamic = null):Dynamic
	{
		if (json == null) json = {};
		
		#if (desktop || air)
		json.autoSave = this.autoSave;
		json.autoSaveInterval = this.autoSaveInterval;
		#end
		
		if (this.customClassVisibilities.numClasses != 0)
		{
			json.customClassVisibilities = this.customClassVisibilities.toJSON();
		}
		
		json.releaseUIFocusOnValidation = this.releaseUIFocusOnValidation;
		if (this.themeCustomValues.hasDifferenceWith(ValEditor.themeDefaultValues))
		{
			json.themeCustomValues = this.themeCustomValues.toJSONSave(null, false, ValEditor.themeDefaultValues);
		}
		json.uiDarkMode = this.uiDarkMode;
		json.undoLevels = this.undoLevels;
		
		return json;
	}
	
}