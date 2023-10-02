package valeditor.ui.feathers.window;

import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.controls.Panel;
import feathers.controls.Radio;
import feathers.core.PopUpManager;
import feathers.core.ToggleGroup;
import feathers.data.ArrayCollection;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalLayoutData;
import openfl.events.Event;
import valedit.ValEditObject;
import valeditor.ui.feathers.Spacing;
import valeditor.ui.feathers.theme.simple.variants.HeaderVariant;

/**
 * ...
 * @author Matse
 */
class ObjectAddWindow extends Panel 
{
	public var cancelCallback(get, set):Void->Void;
	public var newObjectCallback(get, set):Void->Void;
	public var reusableObjects(get, set):Array<ValEditObject>;
	public var reuseObjectCallback(get, set):ValEditObject->Void;
	public var title(get, set):String;
	
	private var _cancelCallback:Void->Void;
	private function get_cancelCallback():Void->Void { return this._cancelCallback; }
	private function set_cancelCallback(value:Void->Void):Void->Void
	{
		return this._cancelCallback = value;
	}
	
	private var _newObjectCallback:Void->Void;
	private function get_newObjectCallback():Void->Void { return this._newObjectCallback; }
	private function set_newObjectCallback(value:Void->Void):Void->Void
	{
		return this._newObjectCallback = value;
	}
	
	private var _reusableObjects:Array<ValEditObject>;
	private function get_reusableObjects():Array<ValEditObject> { return this._reusableObjects; }
	private function set_reusableObjects(value:Array<ValEditObject>):Array<ValEditObject>
	{
		this._reuseObjectCollection.array = value;
		return this._reusableObjects = value;
	}
	
	private var _reuseObjectCallback:ValEditObject->Void;
	private function get_reuseObjectCallback():ValEditObject->Void { return this._reuseObjectCallback; }
	private function set_reuseObjectCallback(value:ValEditObject->Void):ValEditObject->Void
	{
		return this._reuseObjectCallback = value;
	}
	
	private var _title:String = "";
	private function get_title():String { return this._title; }
	private function set_title(value:String):String
	{
		if (value == null) value = "";
		if (this._initialized)
		{
			this._headerGroup.text = value;
		}
		return this._title = value;
	}
	
	private var _headerGroup:Header;
	
	private var _footerGroup:LayoutGroup;
	private var _confirmButton:Button;
	private var _cancelButton:Button;
	
	private var _newObjectGroup:LayoutGroup;
	private var _newObjectRadio:Radio;
	
	private var _reuseObjectGroup:LayoutGroup;
	private var _reuseObjectRadio:Radio;
	private var _reuseObjectList:ListView;
	private var _reuseObjectCollection:ArrayCollection<ValEditObject> = new ArrayCollection();
	
	private var _radioGroup:ToggleGroup;

	public function new() 
	{
		super();
		initializeNow();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var hLayout:HorizontalLayout;
		var vLayout:VerticalLayout;
		
		// header
		this._headerGroup = new Header(this._title);
		this._headerGroup.variant = HeaderVariant.THEME;
		this.header = this._headerGroup;
		
		// footer
		this._footerGroup = new LayoutGroup();
		this._footerGroup.variant = LayoutGroup.VARIANT_TOOL_BAR;
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.CENTER;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.setPadding(Padding.DEFAULT);
		this._footerGroup.layout = hLayout;
		this.footer = this._footerGroup;
		
		this._confirmButton = new Button("confirm", onConfirmButton);
		this._footerGroup.addChild(this._confirmButton);
		
		this._cancelButton = new Button("cancel", onCancelButton);
		this._footerGroup.addChild(this._cancelButton);
		
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.setPadding(Padding.DEFAULT);
		vLayout.gap = Spacing.DEFAULT;
		this.layout = vLayout;
		
		this._radioGroup = new ToggleGroup();
		
		// new object
		this._newObjectGroup = new LayoutGroup();
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.gap = Spacing.HORIZONTAL_GAP;
		this._newObjectGroup.layout = hLayout;
		addChild(this._newObjectGroup);
		
		this._newObjectRadio = new Radio("add as new object");// , false, onNewObjectRadio);
		//this._newObjectRadio.toggleGroup = this._radioGroup;
		this._newObjectGroup.addChild(this._newObjectRadio);
		
		// reuse object
		this._reuseObjectGroup = new LayoutGroup();
		this._reuseObjectGroup.layoutData = new VerticalLayoutData(null, 100);
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.VERTICAL_GAP;
		this._reuseObjectGroup.layout = vLayout;
		addChild(this._reuseObjectGroup);
		
		this._reuseObjectRadio = new Radio("reuse existing object");// , false, onReuseObjectRadio);
		//this._reuseObjectRadio.toggleGroup = this._radioGroup;
		this._reuseObjectGroup.addChild(this._reuseObjectRadio);
		
		this._reuseObjectList = new ListView();
		this._reuseObjectList.layoutData = new VerticalLayoutData(null, 100);
		this._reuseObjectList.dataProvider = this._reuseObjectCollection;
		this._reuseObjectList.itemToText = itemToText;
		this._reuseObjectGroup.addChild(this._reuseObjectList);
		
		this._reuseObjectList.addEventListener(Event.CHANGE, onReuseObjectListChange);
		this._radioGroup.addEventListener(Event.CHANGE, onRadioGroupChange);
		this._newObjectRadio.toggleGroup = this._radioGroup;
		this._reuseObjectRadio.toggleGroup = this._radioGroup;
	}
	
	public function reset():Void
	{
		checkConfirm();
	}
	
	private function checkConfirm():Void
	{
		if (this._reuseObjectRadio.selected)
		{
			this._confirmButton.enabled = this._reuseObjectList.selectedItem != null;
		}
		else
		{
			this._confirmButton.enabled = true;
		}
	}
	
	private function itemToText(item:ValEditObject):String
	{
		return item.id;
	}
	
	private function setNewObjectEnabled(enabled:Bool):Void
	{
		
	}
	
	private function setReuseObjectEnabled(enabled:Bool):Void
	{
		this._reuseObjectList.enabled = enabled;
	}
	
	private function onCancelButton(evt:TriggerEvent):Void
	{
		PopUpManager.removePopUp(this);
		if (this._cancelCallback != null) this._cancelCallback();
	}
	
	private function onConfirmButton(evt:TriggerEvent):Void
	{
		PopUpManager.removePopUp(this);
		
		if (this._newObjectRadio.selected)
		{
			this._newObjectCallback();
		}
		else
		{
			this._reuseObjectCallback(this._reuseObjectList.selectedItem);
		}
	}
	
	private function onRadioGroupChange(evt:Event):Void
	{
		setNewObjectEnabled(this._newObjectRadio.selected);
		setReuseObjectEnabled(this._reuseObjectRadio.selected);
		checkConfirm();
	}
	
	private function onReuseObjectListChange(evt:Event):Void
	{
		checkConfirm();
	}
	
}