package valeditor.ui.feathers.window;

import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.controls.ScrollContainer;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import valedit.ExposedCollection;
import valedit.events.ValueEvent;
import valeditor.editor.settings.EditorSettings;
import valeditor.ui.feathers.FeathersWindows;
import valeditor.ui.feathers.theme.simple.variants.HeaderVariant;
import valeditor.utils.file.FileUtil;

/**
 * ...
 * @author Matse
 */
class EditorSettingsWindow extends Panel 
{
	public var cancelCallback(get, set):Void->Void;
	public var confirmCallback(get, set):Void->Void;
	public var settings(get, set):EditorSettings;
	public var title(get, set):String;
	
	private var _cancelCallback:Void->Void;
	private function get_cancelCallback():Void->Void { return this._cancelCallback; }
	private function set_cancelCallback(value:Void->Void):Void->Void
	{
		return this._cancelCallback = value;
	}
	
	private var _confirmCallback:Void->Void;
	private function get_confirmCallback():Void->Void { return this._confirmCallback; }
	private function set_confirmCallback(value:Void->Void):Void->Void
	{
		return this._confirmCallback = value;
	}
	
	private var _settings:EditorSettings;
	private function get_settings():EditorSettings { return this._settings; }
	private function set_settings(value:EditorSettings):EditorSettings
	{
		this._settings = value;
		if (this._settings != null)
		{
			this._settings.clone(this._backupSettings);
			if (this._initialized)
			{
				this._settingsCollection = ValEditor.edit(this._settings, null, this._editContainer);
				this._settingsCollection.addEventListener(ValueEvent.VALUE_CHANGE, onValueChange);
			}
		}
		else
		{
			if (this._initialized)
			{
				ValEditor.edit(null, null, this._editContainer);
				this._settingsCollection.removeEventListener(ValueEvent.VALUE_CHANGE, onValueChange);
				this._settingsCollection = null;
			}
		}
		return this._settings;
	}
	
	private var _title:String;
	private function get_title():String { return this._title; }
	private function set_title(value:String):String
	{
		if (this._title == value) return value;
		if (this._initialized)
		{
			this._headerGroup.text = value;
		}
		return this._title = value;
	}
	
	private var _headerGroup:Header;
	private var _editContainer:ScrollContainer;
	private var _footerGroup:LayoutGroup;
	private var _restoreDefaultsButton:Button;
	private var _cancelButton:Button;
	private var _confirmButton:Button;
	
	private var _settingsCollection:ExposedCollection;
	private var _backupSettings:EditorSettings = new EditorSettings();
	
	public function new() 
	{
		super();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var hLayout:HorizontalLayout;
		var vLayout:VerticalLayout;
		
		this.layout = new AnchorLayout();
		
		this._headerGroup = new Header(this._title);
		this._headerGroup.variant = HeaderVariant.THEME;
		this.header = this._headerGroup;
		
		this._footerGroup = new LayoutGroup();
		this._footerGroup.variant = LayoutGroup.VARIANT_TOOL_BAR;
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.CENTER;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.setPadding(Padding.DEFAULT);
		this._footerGroup.layout = hLayout;
		this.footer = this._footerGroup;
		
		this._restoreDefaultsButton = new Button("defaults", onRestoreDefaultsButton);
		this._footerGroup.addChild(this._restoreDefaultsButton);
		
		this._cancelButton = new Button("cancel", onCancelButton);
		this._footerGroup.addChild(this._cancelButton);
		
		this._confirmButton = new Button("ok", onConfirmButton);
		this._footerGroup.addChild(this._confirmButton);
		
		this._editContainer = new ScrollContainer();
		this._editContainer.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.DEFAULT;
		vLayout.paddingTop = Padding.DEFAULT;
		vLayout.paddingBottom = Padding.DEFAULT;
		vLayout.paddingLeft = vLayout.paddingRight = Padding.DEFAULT;
		this._editContainer.layout = vLayout;
		addChild(this._editContainer);
		
		if (this._settings != null)
		{
			this._settingsCollection = ValEditor.edit(this._settings, null, this._editContainer);
			this._settingsCollection.addEventListener(ValueEvent.VALUE_CHANGE, onValueChange);
		}
	}
	
	private function onCancelButton(evt:TriggerEvent):Void
	{
		this._backupSettings.clone(this._settings);
		this._settings.apply();
		FeathersWindows.closeWindow(this);
		if (this._cancelCallback != null)
		{
			this._cancelCallback();
		}
	}
	
	private function onConfirmButton(evt:TriggerEvent):Void
	{
		this._settings.apply();
		FileUtil.saveEditorSettings();
		FeathersWindows.closeWindow(this);
		if (this._confirmCallback != null)
		{
			this._confirmCallback();
		}
	}
	
	private function onRestoreDefaultsButton(evt:TriggerEvent):Void
	{
		this._backupSettings.clone(this._settings);
		this._settingsCollection.readValuesFromObject(this._settings, false);
	}
	
	private function onValueChange(evt:ValueEvent):Void
	{
		if (evt.value.propertyName == "uiDarkMode")
		{
			ValEditor.theme.darkMode = evt.value.value;
		}
	}
	
}