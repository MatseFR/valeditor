package valeditor.editor.settings;
import valedit.ExposedCollection;

/**
 * ...
 * @author Matse
 */
class EditorSettings 
{
	public var themeCustomValues:ExposedCollection;
	public var uiDarkMode:Bool = false;
	public var undoLevels:Int = 300;
	
	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		if (this.themeCustomValues != null)
		{
			this.themeCustomValues.pool();
			this.themeCustomValues = null;
		}
	}
	
	public function apply():Void
	{
		this.themeCustomValues.applyToObject(ValEditor.theme);
		ValEditor.theme.darkMode = this.uiDarkMode;
		ValEditor.actionStack.undoLevels = this.undoLevels;
	}
	
	public function clone(?toSettings:EditorSettings):EditorSettings
	{
		if (toSettings == null) toSettings = new EditorSettings();
		
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
		
		if (this.themeCustomValues.hasDifferenceWith(ValEditor.themeDefaultValues))
		{
			json.themeCustomValues = this.themeCustomValues.toJSONSave(null, false, ValEditor.themeDefaultValues);
		}
		json.uiDarkMode = this.uiDarkMode;
		json.undoLevels = this.undoLevels;
		
		return json;
	}
	
}