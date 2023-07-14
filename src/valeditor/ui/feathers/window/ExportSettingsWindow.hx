package valeditor.ui.feathers.window;

import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.controls.ScrollContainer;
import feathers.core.PopUpManager;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import valedit.ExposedCollection;
import valeditor.ValEditor;
import valeditor.editor.settings.ExportSettings;
import valeditor.ui.feathers.theme.simple.variants.HeaderVariant;

/**
 * ...
 * @author Matse
 */
class ExportSettingsWindow extends Panel 
{
	public var confirmCallback(get, set):Void->Void;
	private var _confirmCallback:Void->Void;
	private function get_confirmCallback():Void->Void { return this._confirmCallback; }
	private function set_confirmCallback(value:Void->Void):Void->Void
	{
		return this._confirmCallback = value;
	}
	
	public var settings(get, set):ExportSettings;
	private var _settings:ExportSettings;
	private function get_settings():ExportSettings { return this._settings; }
	private function set_settings(value:ExportSettings):ExportSettings
	{
		if (this._settings == value) return value;
		if (this._initialized)
		{
			this._settingsCollection = ValEditor.edit(value, this._editContainer);
		}
		return this._settings = value;
	}
	
	private var _headerGroup:Header;
	private var _editContainer:ScrollContainer;
	private var _footerGroup:LayoutGroup;
	private var _confirmButton:Button;
	private var _restoreDefaultsButton:Button;
	
	private var _settingsCollection:ExposedCollection;

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
		
		this._headerGroup = new Header("Export Settings");
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
		
		this._confirmButton = new Button("ok", onConfirmButton);
		this._footerGroup.addChild(this._confirmButton);
		
		this._editContainer = new ScrollContainer();
		this._editContainer.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.VERTICAL_GAP;
		vLayout.paddingTop = Spacing.DEFAULT;
		vLayout.paddingBottom = Spacing.DEFAULT;
		vLayout.paddingLeft = vLayout.paddingRight = Padding.DEFAULT;
		this._editContainer.layout = vLayout;
		addChild(this._editContainer);
		
		if (this._settings != null)
		{
			this._settingsCollection = ValEditor.edit(this._settings, this._editContainer);
		}
	}
	
	private function onConfirmButton(evt:TriggerEvent):Void
	{
		PopUpManager.removePopUp(this);
		this.settings = null;
		this.confirmCallback();
	}
	
	private function onRestoreDefaultsButton(evt:TriggerEvent):Void
	{
		this._settingsCollection.restoreDefaultValues();
	}
	
}