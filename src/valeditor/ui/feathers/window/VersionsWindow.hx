package valeditor.ui.feathers.window;

import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import valedit.ValEdit;
import valeditor.ui.feathers.theme.simple.variants.HeaderVariant;

/**
 * ...
 * @author Matse
 */
class VersionsWindow extends Panel 
{
	private var _headerGroup:Header;
	
	private var _footerGroup:LayoutGroup;
	private var _closeButton:Button;
	
	private var _haxeVersion:Label;
	private var _valEditorVersion:Label;
	private var _valEditVersion:Label;
	private var _limeVersion:Label;
	private var _openflVersion:Label;
	#if starling
	private var _starlingVersion:Label;
	#end
	private var _feathersVersion:Label;
	private var _openflJugglerVersion:Label;
	private var _inputActionVersion:Label;

	public function new() 
	{
		super();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var hLayout:HorizontalLayout;
		var vLayout:VerticalLayout;
		
		this._headerGroup = new Header("Versions");
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
		
		this._closeButton = new Button("close", onCloseButton);
		this._footerGroup.addChild(this._closeButton);
		
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.LEFT;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.DEFAULT;
		vLayout.setPadding(Padding.DEFAULT * 2);
		this.layout = vLayout;
		
		this._haxeVersion = new Label("haxe " + ValEdit.HAXE_VERSION);
		addChild(this._haxeVersion);
		
		this._valEditorVersion = new Label("valeditor " + ValEditor.VERSION);
		addChild(this._valEditorVersion);
		
		this._valEditVersion = new Label("valedit " + ValEdit.VERSION);
		addChild(this._valEditVersion);
		
		this._limeVersion = new Label("lime " + ValEdit.LIME_VERSION);
		addChild(this._limeVersion);
		
		this._openflVersion = new Label("openfl " + ValEdit.OPENFL_VERSION);
		addChild(this._openflVersion);
		
		#if starling
		this._starlingVersion = new Label("starling " + ValEdit.STARLING_VERSION);
		addChild(this._starlingVersion);
		#end
		
		this._feathersVersion = new Label("feathersui " + ValEditor.FEATHERS_VERSION);
		addChild(this._feathersVersion);
		
		this._openflJugglerVersion = new Label("openfl-juggler " + ValEdit.OPENFL_JUGGLER_VERSION);
		addChild(this._openflJugglerVersion);
		
		this._inputActionVersion = new Label("inputAction " + ValEditor.INPUT_ACTION_VERSION);
		addChild(this._inputActionVersion);
	}
	
	private function onCloseButton(evt:TriggerEvent):Void
	{
		FeathersWindows.closeWindow(this);
	}
	
}