package ui.feathers.controls.value;
import feathers.controls.Label;
import feathers.controls.TextArea;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import openfl.events.Event;
import ui.feathers.variant.LabelVariant;
import valedit.ExposedValue;
import valedit.events.ValueEvent;
import valedit.ui.IValueUI;
import valedit.value.ExposedText;

/**
 * ...
 * @author Matse
 */
class TextUI extends ValueUI 
{
	override function set_exposedValue(value:ExposedValue):ExposedValue 
	{
		_textValue = cast value;
		return super.set_exposedValue(value);
	}
	
	private var _textValue:ExposedText;
	
	private var _label:Label;
	private var _textArea:TextArea;
	
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
		
		var hLayout:HorizontalLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.TOP;
		hLayout.gap = Spacing.DEFAULT;
		hLayout.paddingRight = Padding.VALUE;
		this.layout = hLayout;
		
		_label = new Label();
		_label.variant = LabelVariant.VALUE_NAME;
		addChild(_label);
		
		_textArea = new TextArea();
		_textArea.layoutData = new HorizontalLayoutData(100);
		addChild(_textArea);
	}
	
	override public function initExposedValue():Void 
	{
		super.initExposedValue();
		_label.text = _exposedValue.name;
		_textArea.restrict = _textValue.restrict;
		_textArea.maxChars = _textValue.maxChars;
		updateEditable();
	}
	
	override public function updateExposedValue(exceptControl:IValueUI = null):Void 
	{
		super.updateExposedValue(exceptControl);
		
		if (_initialized && _exposedValue != null)
		{
			var controlsEnabled:Bool = _controlsEnabled;
			if (controlsEnabled) controlsDisable();
			_textArea.text = _exposedValue.value;
			if (controlsEnabled) controlsEnable();
		}
	}
	
	private function updateEditable():Void
	{
		_textArea.editable = _exposedValue.isEditable;
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
		_textArea.removeEventListener(Event.CHANGE, onInputChange);
	}
	
	override function controlsEnable():Void
	{
		if (_controlsEnabled) return;
		super.controlsEnable();
		_textArea.addEventListener(Event.CHANGE, onInputChange);
	}
	
	private function onInputChange(evt:Event):Void
	{
		_exposedValue.value = _textArea.text;
	}
	
}