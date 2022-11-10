package ui.feathers.controls;

import feathers.controls.IToggle;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.ToggleButtonState;
import feathers.core.IStateContext;
import feathers.core.IStateObserver;
import feathers.core.IUIControl;
import feathers.core.InvalidationFlag;
import feathers.events.FeathersEvent;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.RelativePosition;
import feathers.layout.VerticalAlign;
import feathers.skins.IProgrammaticSkin;
import feathers.text.TextFormat;
import feathers.text.TextFormat.AbstractTextFormat;
import feathers.utils.KeyToState;
import feathers.utils.PointerToState;
import feathers.utils.PointerTrigger;
import flash.events.Event;
import openfl.display.DisplayObject;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import ui.feathers.variant.LayoutGroupVariant;

/**
 * ...
 * @author Matse
 */
@:styleContext
class ToggleLayoutGroup extends LayoutGroup implements IToggle implements IStateContext<ToggleButtonState>
{
	public var currentState(get, never):#if flash Dynamic #else ToggleButtonState #end;
	public var htmlText(get, set):String;
	public var icon:DisplayObject = null;
	public var disabledIcon:DisplayObject = null;
	//@:style
	//public var iconPosition:RelativePosition = RelativePosition.LEFT;
	public var selectedIcon:DisplayObject = null;
	@:style
	public var keepDownStateOnRollOut:Bool = false;
	public var labelVariant(get, set):String;
	public var selected(get, set):Bool;
	@:style
	public var selectedBackgroundSkin:DisplayObject = null;
	public var text(get, set):String;
	public var textFormat:AbstractTextFormat = null;
	public var textFormatDisabled:AbstractTextFormat = null;
	public var textFormatSelected:AbstractTextFormat = null;
	public var toggleable(get, set):Bool;
	
	private var _currentState:ToggleButtonState = ToggleButtonState.UP(false);
	private function get_currentState():#if flash Dynamic #else ToggleButtonState #end
	{
		return _currentState;
	}
	
	override function set_enabled(value:Bool):Bool 
	{
		if (this._enabled == value) return value;
		super.enabled = value;
		if (this._enabled)
		{
			switch (_currentState)
			{
				case ToggleButtonState.DISABLED(selected) :
					this.changeState(ToggleButtonState.UP(selected));
				default : // do nothing
			}
		}
		else
		{
			this.changeState(ToggleButtonState.DISABLED(_selected));
		}
		return this._enabled;
	}
	
	private var _htmlText:String = null;
	private function get_htmlText():String { return _htmlText; }
	private function set_htmlText(value:String):String
	{
		if (_htmlText == value) return value;
		if (_label != null)
		{
			_label.htmlText = value;
		}
		return _htmlText = value;
	}
	
	private var _labelVariant:String;
	private function get_labelVariant():String { return _labelVariant; }
	private function set_labelVariant(value:String):String
	{
		if (_labelVariant == value) return value;
		if (_label != null)
		{
			_label.variant = value;
		}
		return _labelVariant = value;
	}
	
	private var _selected:Bool = false;
	private function get_selected():Bool { return _selected; }
	private function set_selected(value:Bool):Bool
	{
		if (_selected == value) return value;
		_selected = value;
		this.setInvalid(InvalidationFlag.SELECTION);
		this.setInvalid(InvalidationFlag.STATE);
		FeathersEvent.dispatch(this, Event.CHANGE);
		this.changeState(_currentState);
		return _selected;
	}
	
	private var _text:String = null;
	private function get_text():String { return _text; }
	private function set_text(value:String):String
	{
		if (_text == value) return value;
		if (_label != null)
		{
			_label.text = value;
		}
		return _text = value;
	}
	
	private var _toggleable:Bool = true;
	private function get_toggleable():Bool { return this._toggleable; }
	private function set_toggleable(value:Bool):Bool {
		if (this._toggleable == value) {
			return this._toggleable;
		}
		this._toggleable = value;
		return this._toggleable;
	}
	
	public function getIconForState(state:ToggleButtonState):DisplayObject {
		return this._stateToIcon.get(state);
	}
	@style
	public function setIconForState(state:ToggleButtonState, icon:DisplayObject):Void {
		if (!this.setStyle("setIconForState", state)) {
			return;
		}
		var oldIcon = this._stateToIcon.get(state);
		if (oldIcon != null && oldIcon == this._currentIcon) {
			this.removeCurrentIcon(oldIcon);
			this._currentIcon = null;
		}
		if (icon == null) {
			this._stateToIcon.remove(state);
		} else {
			this._stateToIcon.set(state, icon);
		}
		this.setInvalid(STYLES);
	}
	
	private var _stateToSkin:Map<ToggleButtonState, DisplayObject> = new Map();
	public function getSkinForState(state:ToggleButtonState):DisplayObject {
		return this._stateToSkin.get(state);
	}
	@style
	public function setSkinForState(state:ToggleButtonState, skin:DisplayObject):Void {
		if (!this.setStyle("setSkinForState", state)) {
			return;
		}
		var oldSkin = this._stateToSkin.get(state);
		if (oldSkin != null && oldSkin == this._currentBackgroundSkin) {
			this.removeCurrentBackgroundSkin(oldSkin);
			this._currentBackgroundSkin = null;
		}
		if (skin == null) {
			this._stateToSkin.remove(state);
		} else {
			this._stateToSkin.set(state, skin);
		}
		this.setInvalid(STYLES);
	}
	
	private var _stateToTextFormat:Map<ToggleButtonState, AbstractTextFormat> = new Map();
	public function getTextFormatForState(state:ToggleButtonState):AbstractTextFormat {
		return this._stateToTextFormat.get(state);
	}
	@style
	public function setTextFormatForState(state:ToggleButtonState, textFormat:AbstractTextFormat):Void {
		if (!this.setStyle("setTextFormatForState", state)) {
			return;
		}
		if (textFormat == null) {
			this._stateToTextFormat.remove(state);
		} else {
			this._stateToTextFormat.set(state, textFormat);
		}
		this.setInvalid(STYLES);
	}
	
	private var _pointerToState:PointerToState<ToggleButtonState> = null;
	private var _keyToState:KeyToState<ToggleButtonState> = null;
	private var _pointerTrigger:PointerTrigger = null;
	
	private var _stateToIcon:Map<ToggleButtonState, DisplayObject> = new Map();
	private var _currentIcon:DisplayObject;
	private var _label:Label;
	private var _contentGroup:LayoutGroup;
	private var _iconGroup:LayoutGroup;
	
	/**
	   
	**/
	public function new() 
	{
		super();
		this.mouseChildren = false;
		this.buttonMode = true;
		this.useHandCursor = false;
		
		this.addEventListener(MouseEvent.CLICK, toggleGroup_clickHandler);
		this.addEventListener(TouchEvent.TOUCH_TAP, toggleGroup_touchTapHandler);
		this.addEventListener(TriggerEvent.TRIGGER, toggleGroup_triggerHandler);
	}
	
	override private function initialize():Void {
		super.initialize();

		if (this._pointerToState == null) {
			this._pointerToState = new PointerToState(this, this.changeState, UP(false), DOWN(false), HOVER(false));
		}

		if (this._keyToState == null) {
			this._keyToState = new KeyToState(this, this.changeState, UP(false), DOWN(false));
		}

		if (this._pointerTrigger == null) {
			this._pointerTrigger = new PointerTrigger(this);
		}
		
		var hLayout:HorizontalLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		this.layout = hLayout;
		
		_contentGroup = new LayoutGroup();
		_contentGroup.variant = LayoutGroupVariant.TOGGLE_GROUP_CONTENT;
		_contentGroup.layout = new AnchorLayout();
		addChild(_contentGroup);
		
		_iconGroup = new LayoutGroup();
		_iconGroup.layoutData = AnchorLayoutData.middleLeft(0, 2);
		_contentGroup.addChild(_iconGroup);
		
		_label = new Label(_text);
		_label.variant = _labelVariant;
		_label.layoutData = new AnchorLayoutData(null, 0, null, new Anchor(Spacing.DEFAULT, _iconGroup), null, 0);
		_contentGroup.addChild(_label);
	}
	
	override private function update():Void {
		this.commitChanges();
		super.update();
	}

	private function commitChanges():Void {
		var selectionInvalid = this.isInvalid(SELECTION);
		var stylesInvalid = this.isInvalid(STYLES);
		var stateInvalid = this.isInvalid(STATE);
		
		if (selectionInvalid || stateInvalid || stylesInvalid) {
			this.refreshBackgroundSkin();
		}
		
		if (stylesInvalid) {
			this.refreshInteractivity();
		}
		
		if (stylesInvalid || stateInvalid) {
			this.refreshIcon();
		}
		
		if (stylesInvalid || stateInvalid) {
			this.refreshTextStyles();
		}
	}
	
	private function refreshInteractivity():Void {
		this._pointerToState.keepDownStateOnRollOut = this.keepDownStateOnRollOut;
	}
	
	override function refreshBackgroundSkin():Void {
		var oldSkin = this._currentBackgroundSkin;
		this._currentBackgroundSkin = this.getCurrentBackgroundSkin();
		if (this._currentBackgroundSkin == oldSkin) {
			return;
		}
		this.removeCurrentBackgroundSkin(oldSkin);
		this.addCurrentBackgroundSkin(this._currentBackgroundSkin);
	}

	override function getCurrentBackgroundSkin():DisplayObject {
		var result = this._stateToSkin.get(this._currentState);
		if (result != null) {
			return result;
		}
		if (this._selected && this.selectedBackgroundSkin != null) {
			return this.selectedBackgroundSkin;
		}
		return this.backgroundSkin;
	}
	
	private function refreshTextStyles():Void {
		var textFormat = this.getCurrentTextFormat();
		if (textFormat != null)
		{
			_label.textFormat = textFormat;
		}
	}
	
	private function getCurrentTextFormat():TextFormat {
		var result = this._stateToTextFormat.get(this._currentState);
		if (result != null) {
			return result;
		}
		if (!this._enabled && this.textFormatDisabled != null) {
			return this.textFormatDisabled;
		}
		if (this._selected && this.textFormatSelected != null) {
			return this.textFormatSelected;
		}
		return this.textFormat;
	}
	
	private function refreshIcon():Void {
		var oldIcon = this._currentIcon;
		this._currentIcon = this.getCurrentIcon();
		if (this._currentIcon == oldIcon) {
			return;
		}
		this.removeCurrentIcon(oldIcon);
		this.addCurrentIcon(this._currentIcon);
	}
	
	private function getCurrentIcon():DisplayObject {
		var result = this._stateToIcon.get(this._currentState);
		if (result != null) {
			return result;
		}
		if (!this._enabled && this.disabledIcon != null) {
			return this.disabledIcon;
		}
		if (this._selected && this.selectedIcon != null) {
			return this.selectedIcon;
		}
		return this.icon;
	}
	
	private function addCurrentIcon(icon:DisplayObject):Void {
		if ((icon is IUIControl)) {
			cast(icon, IUIControl).initializeNow();
		}
		if ((icon is IProgrammaticSkin)) {
			cast(icon, IProgrammaticSkin).uiContext = _iconGroup;
		}
		if ((icon is IStateObserver)) {
			cast(icon, IStateObserver).stateContext = this;
		}
		_iconGroup.addChild(icon);
	}
	
	private function removeCurrentIcon(icon:DisplayObject):Void {
		if (icon == null) {
			return;
		}
		if ((icon is IProgrammaticSkin)) {
			cast(icon, IProgrammaticSkin).uiContext = null;
		}
		if ((icon is IStateObserver)) {
			cast(icon, IStateObserver).stateContext = null;
		}
		if (icon.parent == _iconGroup)
		{
			_iconGroup.removeChild(icon);
		}
	}
	
	private function changeState(state:ToggleButtonState):Void
	{
		var toggleState = cast(state, ToggleButtonState);
		if (!this._enabled) toggleState = ToggleButtonState.DISABLED(_selected);
		
		switch (toggleState)
		{
			case ToggleButtonState.UP(selected) :
				if (_selected != selected)
				{
					toggleState = ToggleButtonState.UP(_selected);
				}
			case ToggleButtonState.DOWN(selected) :
				if (_selected != selected)
				{
					toggleState = ToggleButtonState.DOWN(_selected);
				}
			case ToggleButtonState.HOVER(selected) :
				if (_selected != selected)
				{
					toggleState = ToggleButtonState.HOVER(_selected);
				}
			case ToggleButtonState.DISABLED(selected) :
				if (_selected != selected)
				{
					toggleState = ToggleButtonState.DISABLED(_selected);
				}
			default : // do nothing
		}
		if (this._currentState == toggleState) {
			return;
		}
		this._currentState = toggleState;
		this.setInvalid(STATE);
		FeathersEvent.dispatch(this, FeathersEvent.STATE_CHANGE);
	}
	
	private function toggleGroup_clickHandler(event:MouseEvent):Void {
		if (!this._enabled) {
			event.stopImmediatePropagation();
			return;
		}
	}

	private function toggleGroup_touchTapHandler(event:TouchEvent):Void {
		if (!this._enabled) {
			event.stopImmediatePropagation();
			return;
		}
	}

	private function toggleGroup_triggerHandler(event:TriggerEvent):Void {
		if (!this._enabled || !this._toggleable) {
			return;
		}
		this.selected = !this._selected;
	}
	
}