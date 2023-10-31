package valeditor.ui.feathers.window;

import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.Panel;
import feathers.core.PopUpManager;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import valeditor.ui.feathers.theme.simple.variants.HeaderVariant;

/**
 * ...
 * @author Matse
 */
class StartMenuWindow extends Panel 
{
	public var newFileCallback(get, set):Void->Void;
	public var loadFileCallback(get, set):Void->Void;
	#if desktop
	public var loadRecentFileCallback(get, set):String->Void;
	#end
	
	private var _newFileCallback:Void->Void;
	private function get_newFileCallback():Void->Void { return this._newFileCallback; }
	private function set_newFileCallback(value:Void->Void):Void->Void
	{
		return this._newFileCallback = value;
	}
	
	private var _loadFileCallback:Void->Void;
	private function get_loadFileCallback():Void->Void { return this._loadFileCallback; }
	private function set_loadFileCallback(value:Void->Void):Void->Void
	{
		return this._loadFileCallback = value;
	}
	
	#if desktop
	private var _loadRecentFileCallback:String->Void;
	private function get_loadRecentFileCallback():String->Void { return this._loadRecentFileCallback; }
	private function set_loadRecentFileCallback(value:String->Void):String->Void
	{
		return this._loadRecentFileCallback = value;
	}
	#end
	
	private var _headerGroup:Header;
	private var _newFileButton:Button;
	private var _loadFileButton:Button;
	
	public function new() 
	{
		super();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		this._headerGroup = new Header("Start Menu");
		this._headerGroup.variant = HeaderVariant.THEME;
		this.header = this._headerGroup;
		
		var vLayout:VerticalLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.MIDDLE;
		vLayout.gap = Spacing.DEFAULT;
		vLayout.setPadding(Padding.DEFAULT);
		this.layout = vLayout;
		
		this._newFileButton = new Button("New File", onNewFileButton);
		addChild(this._newFileButton);
		
		this._loadFileButton = new Button("Load File", onLoadFileButton);
		addChild(this._loadFileButton);
	}
	
	private function onNewFileButton(evt:TriggerEvent):Void
	{
		this._newFileCallback();
		PopUpManager.removePopUp(this);
	}
	
	private function onLoadFileButton(evt:TriggerEvent):Void
	{
		this._loadFileCallback();
		PopUpManager.removePopUp(this);
	}
	
}