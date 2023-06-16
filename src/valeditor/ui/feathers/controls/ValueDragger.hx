package valeditor.ui.feathers.controls;

import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.TextInput;
import feathers.core.FocusManager;
import feathers.core.IFocusObject;
import feathers.events.FeathersEvent;
import feathers.text.TextFormat;
import feathers.text.TextFormat.AbstractTextFormat;
import feathers.utils.ExclusivePointer;
import feathers.utils.MathUtil;
import haxe.ds.Map;
import openfl.display.DisplayObject;
import openfl.display.Stage;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.ui.Keyboard;

/**
 * ...
 * @author Matse
 */
@:styleContext
class ValueDragger extends LayoutGroup implements IFocusObject
{
	static public var CHILD_VARIANT_INPUT:String = "valueDragger_input";
	static public var CHILD_VARIANT_LABEL:String = "valueDragger_label" ;
	
	public var currentState(get, never):#if flash Dynamic #else ValueDraggerState #end;
	public var defaultBackgroundSkin:DisplayObject;
	public var defaultLabelSkin:DisplayObject;
	/** value to use when user sets the text input empty */
	public var defaultValue(get, set):Float;
	public var disabledTextFormat:AbstractTextFormat;
	public var isIntValue(get, set):Bool;
	public var liveDragging:Bool = true;
	public var liveInput:Bool = true;
	public var maximum(get, set):Float;
	public var minimum(get, set):Float;
	public var dragScaleFactor(get, set):Float;
	/** this property exists to allow adjusting the drag to a zoom level or something similar */
	public var secondaryDragScaleFactor(get, set):Float;
	/** if this is not null it will be called during drag and secondaryDragScaleFactor will be ignored */
	public var secondaryDragScaleFactorFunction(get, set):Void->Float;
	public var step(get, set):Float;
	public var textFormat:AbstractTextFormat;
	public var value(get, set):Float;
	
	private var _currentState:ValueDraggerState = UP;
	private function get_currentState():#if flash Dynamic #else ValueDraggerState #end {
		return this._currentState;
	}
	
	private var _defaultValue:Float = 0.0;
	private function get_defaultValue():Float { return this._defaultValue; }
	private function set_defaultValue(value:Float):Float
	{
		if (this._defaultValue == value) return value;
		this._defaultValue = value;
		this.setInvalid(DATA);
		return this._defaultValue;
	}
	
	private var _dragScaleFactor:Float = 1.0;
	private function get_dragScaleFactor():Float { return this._dragScaleFactor; }
	private function set_dragScaleFactor(value:Float):Float
	{
		return this._dragScaleFactor = value;
	}
	
	override function set_enabled(value:Bool):Bool 
	{
		super.enabled = value;
		if (this._enabled)
		{
			if (this._currentState == DISABLED)
			{
				this.changeState(UP);
			}
		}
		else
		{
			this.changeState(DISABLED);
		}
		return this._enabled;
	}
	
	private var _isIntValue:Bool;
	private function get_isIntValue():Bool { return this._isIntValue; }
	private function set_isIntValue(value:Bool):Bool
	{
		if (this._isIntValue == value) return value;
		this._isIntValue = value;
		this.setInvalid(DATA);
		return this._isIntValue;
	}
	
	private var _maximum:Float = 1.0;
	private function get_maximum():Float { return this._maximum; }
	private function set_maximum(value:Float):Float
	{
		if (this._maximum == value) return value;
		this._maximum = value;
		this.setInvalid(DATA);
		return this._maximum;
	}
	
	private var _minimum:Float = 0.0;
	private function get_minimum():Float { return this._minimum; }
	private function set_minimum(value:Float):Float
	{
		if (this._minimum == value) return value;
		this._minimum = value;
		this.setInvalid(DATA);
		return this._minimum;
	}
	
	private var _secondaryDragScaleFactor:Float = 1.0;
	private function get_secondaryDragScaleFactor():Float { return this._secondaryDragScaleFactor; }
	private function set_secondaryDragScaleFactor(value:Float):Float
	{
		return this._secondaryDragScaleFactor = value;
	}
	
	private var _secondaryDragScaleFactorFunction:Void->Float;
	private function get_secondaryDragScaleFactorFunction():Void->Float { return this._secondaryDragScaleFactorFunction; }
	private function set_secondaryDragScaleFactorFunction(value:Void->Float):Void->Float
	{
		return this._secondaryDragScaleFactorFunction;
	}
	
	private var _step:Float = 0.01;
	private function get_step():Float { return this._step; }
	private function set_step(value:Float):Float
	{
		if (this._step == value) return value;
		
		#if flash
		var str = Std.string(value);
		var index = str.indexOf(".");
		if (index != -1)
		{
			this._floatPrecision = str.length - 1 - index;
		}
		#end
		
		this._step = value;
		this.setInvalid(DATA);
		return this._step;
	}
	
	private var _value:Float = 0.0;
	private function get_value():Float { return this._value; }
	private function set_value(value:Float):Float
	{
		// don't restrict a value that has been passed in from an external
		// source to the minimum/maximum/snapInterval
		// assume that the user knows what they are doing
		if (this._value == value) return value;
		
		this._isDefaultValue = false;
		if (this._isIntValue) value = Std.int(value);
		this._value = value;
		this.setInvalid(DATA);
		if (this.liveDragging || !this._isDragging)
		{
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
		return this._value;
	}
	
	private var _isDefaultValue:Bool = true;
	private var _isDragging:Bool;
	private var _pointerStartX:Float;
	private var _pointerStartY:Float;
	private var _beforeDragValue:Float;
	private var _hasMoved:Bool;
	private var _moveValue:Float;
	
	#if flash // TODO : check if other targets do weird things with float values
	private var _floatPrecision:Int = 2; // this corresponds to the default step value (0.01)
	#end
	
	private var _dragLabel:Label;
	private var _input:TextInput;
	
	private var _stateToSkin:Map<ValueDraggerState, DisplayObject> = new Map();
	private var _stateToLabelSkin:Map<ValueDraggerState, DisplayObject> = new Map();
	private var _stateToLabelTextFormat:Map<ValueDraggerState, AbstractTextFormat> = new Map();
	
	private var _inputHasFocus:Bool;
	
	public function getSkinForState(state:ValueDraggerState):DisplayObject
	{
		return this._stateToSkin.get(state);
	}
	
	public function setSkinForState(state:ValueDraggerState, skin:DisplayObject):Void
	{
		if (!this.setStyle("setSkinForState", state)) return;
		
		if (skin == null)
		{
			this._stateToSkin.remove(state);
		}
		else
		{
			this._stateToSkin.set(state, skin);
		}
		this.setInvalid(STYLES);
	}
	
	public function getLabelSkinForState(state:ValueDraggerState):DisplayObject
	{
		return this._stateToLabelSkin.get(state);
	}
	
	public function setLabelSkinForState(state:ValueDraggerState, skin:DisplayObject):Void
	{
		if (!this.setStyle("setLabelSkinForState", state)) return;
		
		if (skin == null)
		{
			this._stateToLabelSkin.remove(state);
		}
		else
		{
			this._stateToLabelSkin.set(state, skin);
		}
		this.setInvalid(STYLES);
	}
	
	public function getLabelTextFormatForState(state:ValueDraggerState):AbstractTextFormat
	{
		return this._stateToLabelTextFormat.get(state);
	}
	
	public function setLabelTextFormatForState(state:ValueDraggerState, textFormat:AbstractTextFormat):Void
	{
		if (!this.setStyle("setLabelTextFormatForState", state)) return;
		if (textFormat == null)
		{
			this._stateToLabelTextFormat.remove(state);
		}
		else
		{
			this._stateToLabelTextFormat.set(state, textFormat);
		}
		this.setInvalid(STYLES);
	}

	public function new() 
	{
		super();
		
		//this.buttonMode = true;
		this.tabEnabled = true;
		this.tabChildren = false;
		this.focusRect = null;
	}
	
	@:access(feathers.controls.TextInput.textField)
	override function initialize():Void 
	{
		super.initialize();
		
		// if the user hasn't changed the value, automatically restrict it based
		// on things like minimum, maximum, and snapInterval
		// if the user has changed the value, assume that they know what they're
		// doing and don't want hand holding
		if (this._isDefaultValue) {
			// use the setter
			this.value = this.restrictValue(this._value);
		}
		
		if (this._dragLabel == null)
		{
			this._dragLabel = new Label();
			this._dragLabel.variant = CHILD_VARIANT_LABEL;
			this._dragLabel.addEventListener(MouseEvent.MOUSE_OVER, dragLabel_mouseOverHandler);
			this._dragLabel.addEventListener(MouseEvent.MOUSE_OUT, dragLabel_mouseOutHandler);
			this._dragLabel.addEventListener(MouseEvent.MOUSE_DOWN, dragLabel_mouseDownHandler);
			this._dragLabel.addEventListener(MouseEvent.CLICK, dragLabel_clickHandler);
		}
		addChild(this._dragLabel);
		
		if (this._input == null)
		{
			this._input = new TextInput();
			this._input.variant = CHILD_VARIANT_INPUT;
			this._input.addEventListener(Event.CHANGE, input_changeHandler);
			this._input.addEventListener(FocusEvent.FOCUS_IN, input_focusInHandler);
			this._input.addEventListener(FocusEvent.FOCUS_OUT, input_focusOutHandler);
		}
		this._input.initializeNow();
		this._input.textField.addEventListener(KeyboardEvent.KEY_UP, input_keyUpHandler);
		
		this.addEventListener(FocusEvent.FOCUS_IN, focusInHandler);
		this.addEventListener(FocusEvent.FOCUS_OUT, focusOutHandler);
	}
	
	override function update():Void 
	{
		super.update();
		
		var dataInvalid = this.isInvalid(DATA);
		var stateInvalid = this.isInvalid(STATE);
		var stylesInvalid = this.isInvalid(STYLES);
		
		if (dataInvalid)
		{
			#if flash // TODO : check if other targets do weird things with float values
			var str:String = Std.string(MathUtil.roundToPrecision(this._value, this._floatPrecision));
			#else
			var str:String = Std.string(this._value);
			#end
			if (this._dragLabel != null) this._dragLabel.text = str;
			if (this._input != null) this._input.text = str;
			
			// update input restrict
			if (this._minimum < 0.0)
			{
				if (this._isIntValue)
				{
					this._input.restrict = "0123456789";
				}
				else
				{
					this._input.restrict = "0123456789.";
				}
			}
			else
			{
				if (this._isIntValue)
				{
					this._input.restrict = "-0123456789";
				}
				else
				{
					this._input.restrict = "-0123456789.";
				}
			}
		}
		
		if (stateInvalid || stylesInvalid)
		{
			this.refreshEnabled();
		}
		
		if (stylesInvalid)
		{
			refreshStyles();
		}
		
		if (stateInvalid)
		{
			this.refreshState();
		}
	}
	
	private function changeState(state:ValueDraggerState):Void
	{
		if (!this._enabled)
		{
			state = DISABLED;
		}
		if (this._currentState == state) return;
		
		this._currentState = state;
		this.setInvalid(STATE);
		this.setInvalid(STYLES);
		FeathersEvent.dispatch(this, FeathersEvent.STATE_CHANGE);
	}
	
	private function refreshStyles():Void
	{
		this.backgroundSkin = getCurrentSkin();
		this._dragLabel.textFormat = getCurrentLabelTextFormat();
		this._dragLabel.backgroundSkin = getCurrentLabelSkin();
	}
	
	private function refreshEnabled():Void
	{
		this._dragLabel.enabled = this._enabled;
		this._input.enabled = this._enabled;
	}
	
	private function refreshState():Void
	{
		if (this._currentState == INPUT)
		{
			if (this._input.parent == null)
			{
				if (this._dragLabel.parent != null)
				{
					this.removeChild(this._dragLabel);
				}
				this.addChild(this._input);
				if (this.focusManager != null)
				{
					FocusManager.setFocus(this._input);
					this._input.selectAll();
				}
				else if (this.stage != null)
				{
					this.stage.focus = this._input;
					this._input.selectAll();
				}
			}
		}
		else
		{
			if (this._dragLabel.parent == null)
			{
				if (this._input.parent != null)
				{
					this.removeChild(this._input);
				}
				this.addChild(this._dragLabel);
			}
		}
	}
	
	private function getCurrentSkin():DisplayObject
	{
		var result = this._stateToSkin.get(this._currentState);
		if (result != null)
		{
			return result;
		}
		return this.defaultBackgroundSkin;
	}
	
	private function getCurrentLabelSkin():DisplayObject
	{
		var result = this._stateToLabelSkin.get(this._currentState);
		if (result != null)
		{
			return result;
		}
		return this.defaultLabelSkin;
	}
	
	private function getCurrentLabelTextFormat():TextFormat
	{
		var result = this._stateToLabelTextFormat.get(this._currentState);
		if (result != null)
		{
			return result;
		}
		if (!this._enabled && this.disabledTextFormat != null)
		{
			return this.disabledTextFormat;
		}
		return this.textFormat;
	}
	
	private function restrictValue(value:Float):Float
	{
		if (this._step != 0.0 && value != this._minimum && value != this._maximum)
		{
			value = MathUtil.roundToNearest(value, this._step);
		}
		if (value < this._minimum)
		{
			value = this._minimum;
		}
		else if (value > this._maximum)
		{
			value = this._maximum;
		}
		return value;
	}
	
	private function dragLabel_mouseOverHandler(evt:MouseEvent):Void
	{
		if (!this._enabled || this._currentState != UP) return;
		
		changeState(HOVER);
	}
	
	private function dragLabel_mouseOutHandler(evt:MouseEvent):Void
	{
		if (!this._enabled || this._currentState != HOVER) return;
		
		changeState(UP);
	}
	
	private function dragLabel_clickHandler(evt:MouseEvent):Void
	{
		if (!this._enabled || this._hasMoved) return;
		
		var exclusivePointer = ExclusivePointer.forStage(this.stage);
		var result = exclusivePointer.claimMouse(this);
		if (!result) return;
		
		changeState(INPUT);
	}
	
	private function dragLabel_mouseDownHandler(evt:MouseEvent):Void
	{
		if (!this._enabled || this.stage == null) return;
		
		var exclusivePointer = ExclusivePointer.forStage(this.stage);
		var result = exclusivePointer.claimMouse(this);
		if (!result) return;
		
		this.stage.addEventListener(MouseEvent.MOUSE_MOVE, dragLabel_stage_mouseMoveHandler);
		this.stage.addEventListener(MouseEvent.MOUSE_UP, dragLabel_stage_mouseUpHandler);
		
		this._hasMoved = false;
		this._moveValue = 0;
		this._beforeDragValue = this._value;
		this._pointerStartX = this.mouseX;
		this._pointerStartY = this.mouseY;
		this._isDragging = true;
		
		changeState(DRAG);
	}
	
	private function dragLabel_stage_mouseMoveHandler(evt:MouseEvent):Void
	{
		this._hasMoved = true;
		
		var moveX:Float = this.mouseX - this._pointerStartX;
		var moveY:Float = -(this.mouseY - this._pointerStartY);
		this._pointerStartX = this.mouseX;
		this._pointerStartY = this.mouseY;
		
		var moveDistance:Float;
		
		if (Math.abs(moveX) > Math.abs(moveY))
		{
			moveDistance = moveX;
		}
		else
		{
			moveDistance = moveY;
		}
		
		if (this._secondaryDragScaleFactorFunction == null)
		{
			this._moveValue += moveDistance * this._dragScaleFactor * this._secondaryDragScaleFactor;
		}
		else
		{
			this._moveValue += moveDistance * this._dragScaleFactor * this._secondaryDragScaleFactorFunction();
		}
		
		if (Math.abs(this._moveValue) >= this._step)
		{
			var changeValue:Float = this._moveValue;
			if (this._step != 0.0)
			{
				changeValue = MathUtil.roundToNearest(changeValue, this._step);
			}
			this.value = restrictValue(this._value + changeValue);
			this._moveValue -= changeValue;
		}
	}
	
	private function dragLabel_stage_mouseUpHandler(evt:MouseEvent):Void
	{
		var stage:Stage = cast evt.currentTarget;
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, dragLabel_stage_mouseMoveHandler);
		stage.removeEventListener(MouseEvent.MOUSE_UP, dragLabel_stage_mouseUpHandler);
		this._isDragging = false;
		changeState(UP);
		if (!this.liveDragging)
		{
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}
	
	private function focusInHandler(evt:FocusEvent):Void
	{
		changeState(INPUT);
	}
	
	private function focusOutHandler(evt:FocusEvent):Void
	{
		changeState(UP);
	}
	
	private function input_changeHandler(evt:Event):Void
	{
		if (!this._inputHasFocus || !this.liveInput) return;
		
		if (this._input.text == "") return;
		this.value = restrictValue(Std.parseFloat(this._input.text));
	}
	
	private function input_focusInHandler(evt:FocusEvent):Void
	{
		this._inputHasFocus = true;
	}
	
	private function input_focusOutHandler(evt:FocusEvent):Void
	{
		if (!this._inputHasFocus) return;
		this._inputHasFocus = false;
		
		changeState(UP);
	}
	
	private function input_keyUpHandler(evt:KeyboardEvent):Void
	{
		if (evt.keyCode == Keyboard.ENTER || evt.keyCode == Keyboard.NUMPAD_ENTER)
		{
			if (!this.liveInput && this._input.text != "")
			{
				this.value = restrictValue(Std.parseFloat(this._input.text));
			}
			else
			{
				setInvalid(DATA);
			}
			if (this.focusManager != null)
			{
				this.focusManager.focus = null;
			}
			else if (this.stage != null)
			{
				this.stage.focus = null;
			}
		}
		else if (evt.keyCode == Keyboard.ESCAPE)
		{
			setInvalid(DATA);
			if (this.focusManager != null)
			{
				this.focusManager.focus = null;
			}
			else if (this.stage != null)
			{
				this.stage.focus = null;
			}
		}
	}
	
}