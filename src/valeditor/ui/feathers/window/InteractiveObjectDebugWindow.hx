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
import valeditor.ui.InteractiveObjectController;
import valeditor.ui.feathers.theme.simple.variants.HeaderVariant;

/**
 * ...
 * @author Matse
 */
class InteractiveObjectDebugWindow extends Panel 
{
	public var controller(get, set):InteractiveObjectController;
	
	private var _controller:InteractiveObjectController;
	private function get_controller():InteractiveObjectController { return this._controller; }
	private function set_controller(value:InteractiveObjectController):InteractiveObjectController
	{
		if (this._controller == value) return value;
		if (this._initialized)
		{
			ValEditor.edit(value, this._contentGroup);
		}
		return this._controller = value;
	}
	
	private var _headerGroup:Header;
	
	private var _footerGroup:LayoutGroup;
	private var _okButton:Button;
	
	private var _contentGroup:ScrollContainer;
	
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
		
		this._headerGroup = new Header("Interactive Object Debug");
		this._headerGroup.variant = HeaderVariant.THEME;
		this.header = this._headerGroup;
		
		this._footerGroup = new LayoutGroup();
		this._footerGroup.variant = LayoutGroup.VARIANT_TOOL_BAR;
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.CENTER;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.setPadding(Padding.DEFAULT);
		this._footerGroup.layout = hLayout;
		this.footer = _footerGroup;
		
		this._okButton = new Button("ok", onOkButton);
		this._footerGroup.addChild(this._okButton);
		
		this._contentGroup = new ScrollContainer();
		this._contentGroup.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.VERTICAL_GAP;
		vLayout.paddingTop = Spacing.DEFAULT;
		vLayout.paddingBottom = Spacing.DEFAULT;
		vLayout.paddingLeft = vLayout.paddingRight = Padding.DEFAULT;
		this._contentGroup.layout = vLayout;
		addChild(this._contentGroup);
		
		if (this._controller != null)
		{
			ValEditor.edit(this._controller, this._contentGroup);
		}
	}
	
	private function onOkButton(evt:TriggerEvent):Void
	{
		this._controller = null;
		FeathersWindows.closeWindow(this);
	}
	
}