package valeditor.ui.feathers.controls.value;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.TextArea;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import openfl.events.Event;
import valeditor.ui.feathers.variant.LabelVariant;
import valedit.ExposedValue;
import valedit.events.ValueEvent;
import valedit.ui.IValueUI;
import valedit.value.ExposedText;
import valeditor.ui.feathers.Padding;
import valeditor.ui.feathers.Spacing;
import valeditor.ui.feathers.controls.ValueWedge;

/**
 * ...
 * @author Matse
 */
class TextUI extends ValueUI 
{
	override function set_exposedValue(value:ExposedValue):ExposedValue 
	{
		this._textValue = cast value;
		return super.set_exposedValue(value);
	}
	
	private var _textValue:ExposedText;
	
	private var _mainGroup:LayoutGroup;
	private var _label:Label;
	private var _textArea:TextArea;
	
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
		hLayout.verticalAlign = VerticalAlign.TOP;
		hLayout.gap = Spacing.DEFAULT;
		this._mainGroup.layout = hLayout;
		addChild(this._mainGroup);
		
		this._label = new Label();
		this._label.variant = LabelVariant.VALUE_NAME;
		this._mainGroup.addChild(this._label);
		
		this._textArea = new TextArea();
		this._textArea.layoutData = new HorizontalLayoutData(100);
		this._mainGroup.addChild(this._textArea);
		
		this._nullGroup = new LayoutGroup();
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.gap = Spacing.DEFAULT;
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
		this._textArea.restrict = this._textValue.restrict;
		this._textArea.maxChars = this._textValue.maxChars;
		if (this._exposedValue.isNullable)
		{
			if (this._nullGroup.parent == null)
			{
				addChild(this._nullGroup);
			}
		}
		else
		{
			if (this._nullGroup.parent != null)
			{
				removeChild(this._nullGroup);
			}
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
			this._textArea.text = this._exposedValue.value;
			if (controlsEnabled) controlsEnable();
		}
	}
	
	private function updateEditable():Void
	{
		this._textArea.enabled = this._exposedValue.isEditable;
		this._nullButton.enabled = this._exposedValue.isEditable;
	}
	
	override function onValueEditableChange(evt:ValueEvent):Void 
	{
		super.onValueEditableChange(evt);
		updateEditable();
	}
	
	override function controlsDisable():Void
	{
		if (!this._controlsEnabled) return;
		super.controlsDisable();
		this._textArea.removeEventListener(Event.CHANGE, onInputChange);
		this._nullButton.removeEventListener(TriggerEvent.TRIGGER, onNullButton);
	}
	
	override function controlsEnable():Void
	{
		if (this._controlsEnabled) return;
		super.controlsEnable();
		this._textArea.addEventListener(Event.CHANGE, onInputChange);
		this._nullButton.addEventListener(TriggerEvent.TRIGGER, onNullButton);
	}
	
	private function onInputChange(evt:Event):Void
	{
		this._exposedValue.value = this._textArea.text;
	}
	
	private function onNullButton(evt:TriggerEvent):Void
	{
		this._textArea.text = "";
		this._exposedValue.value = null;
	}
	
}