package valeditor.ui.feathers.controls.value;

import feathers.controls.Button;
import feathers.controls.Check;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import openfl.events.Event;
import valeditor.ui.feathers.controls.value.ValueUI;
import valeditor.ui.feathers.variant.LabelVariant;
import valedit.events.ValueEvent;
import valedit.ui.IValueUI;
import valeditor.ui.feathers.Padding;
import valeditor.ui.feathers.Spacing;
import valeditor.ui.feathers.controls.ValueWedge;

/**
 * ...
 * @author Matse
 */
class BoolUI extends ValueUI 
{
	private var _mainGroup:LayoutGroup;
	private var _label:Label;
	private var _check:Check;
	private var _nullLabel:Label;
	
	private var _nullGroup:LayoutGroup;
	private var _wedge:ValueWedge;
	private var _nullButton:Button;
	
	/**
	   
	**/
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
		
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.MINIMAL;
		vLayout.paddingRight = Padding.VALUE;
		this.layout = vLayout;
		
		this._mainGroup = new LayoutGroup();
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.gap = Spacing.DEFAULT;
		this._mainGroup.layout = hLayout;
		addChild(this._mainGroup);
		
		this._label = new Label();
		this._label.variant = LabelVariant.VALUE_NAME;
		this._mainGroup.addChild(_label);
		
		this._check = new Check();
		this._mainGroup.addChild(_check);
		
		this._nullGroup = new LayoutGroup();
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.gap = Spacing.DEFAULT;
		hLayout.paddingRight = Padding.VALUE;
		this._nullGroup.layout = hLayout;
		
		this._wedge = new ValueWedge();
		this._nullGroup.addChild(this._wedge);
		
		this._nullButton = new Button("set to null");
		this._nullButton.layoutData = new HorizontalLayoutData(100);
		this._nullGroup.addChild(this._nullButton);
	}
	
	override public function initExposedValue():Void 
	{
		super.initExposedValue();
		this._label.text = this._exposedValue.name;
		if (this._exposedValue.isNullable)
		{
			if (this._nullGroup.parent == null)
			{
				addChild(this._nullGroup);
			}
			this._check.text = this._exposedValue.value == null ? "(null)" : "";
		}
		else
		{
			if (this._nullGroup.parent != null)
			{
				removeChild(this._nullGroup);
			}
			this._check.text = "";
		}
		updateEditable();
	}
	
	override public function updateExposedValue(exceptControl:IValueUI = null):Void 
	{
		super.updateExposedValue(exceptControl);
		
		if (this._initialized && this._exposedValue != null)
		{
			var controlsEnabled:Bool = this._controlsEnabled;
			if (controlsEnabled) controlsDisable();
			if (this._exposedValue.value == null)
			{
				this._check.text = "(null)";
			}
			else
			{
				this._check.text = "";
				this._check.selected = this._exposedValue.value;
			};
			if (controlsEnabled) controlsEnable();
		}
	}
	
	private function updateEditable():Void
	{
		this.enabled = this._exposedValue.isEditable;
		this._label.enabled = this._exposedValue.isEditable;
		this._check.enabled = this._exposedValue.isEditable;
		this._nullButton.enabled = this._exposedValue.isEditable;
	}
	
	override function onValueEditableChange(evt:ValueEvent):Void 
	{
		super.onValueEditableChange(evt);
		updateEditable();
	}
	
	override function controlsDisable():Void 
	{
		if (!_controlsEnabled) return;
		super.controlsDisable();
		this._check.removeEventListener(Event.CHANGE, onCheckChange);
		this._nullButton.removeEventListener(TriggerEvent.TRIGGER, onNullButton);
	}
	
	override function controlsEnable():Void
	{
		if (_controlsEnabled) return;
		super.controlsEnable();
		this._check.addEventListener(Event.CHANGE, onCheckChange);
		this._nullButton.addEventListener(TriggerEvent.TRIGGER, onNullButton);
	}
	
	private function onCheckChange(evt:Event):Void
	{
		this._check.text = "";
		this._exposedValue.value = this._check.selected;
	}
	
	private function onNullButton(evt:TriggerEvent):Void
	{
		this._exposedValue.value = null;
		this._check.text = "(null)";
	}
	
}