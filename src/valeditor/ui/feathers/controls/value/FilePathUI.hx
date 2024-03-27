package valeditor.ui.feathers.controls.value;
import valeditor.ui.feathers.controls.value.base.ValueUI;
import openfl.events.FocusEvent;
import valeditor.events.ValueUIEvent;
import openfl.errors.Error;
import valeditor.editor.action.value.ValueUIUpdate;
import valeditor.editor.action.value.ValueChange;
import valeditor.editor.action.MultiAction;
import openfl.events.Event;
import feathers.controls.TextInput;
#if desktop
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import valedit.value.base.ExposedValue;
import valedit.events.ValueEvent;
import valedit.ui.IValueUI;
import valedit.value.ExposedFilePath;
import valeditor.ui.feathers.controls.ValueWedge;
import valeditor.ui.feathers.variant.LabelVariant;
import valeditor.utils.file.FileSelectorDesktop;

/**
 * Desktop targets only (Neko, CPP, Air...)
 * @author Matse
 */
class FilePathUI extends ValueUI 
{
	static private var _POOL:Array<FilePathUI> = new Array<FilePathUI>();
	
	static public function disposePool():Void
	{
		_POOL.resize(0);
	}
	
	static public function fromPool():FilePathUI
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new FilePathUI();
	}
	
	override function set_exposedValue(value:ExposedValue):ExposedValue 
	{
		if (value == null)
		{
			this._filePathValue = null;
		}
		else
		{
			this._filePathValue = cast value;
		}
		return super.set_exposedValue(value);
	}
	
	private var _filePathValue:ExposedFilePath;
	
	private var _mainGroup:LayoutGroup;
	private var _label:Label;
	private var _pathInput:TextInput;
	
	private var _controlGroup:LayoutGroup;
	private var _wedge:ValueWedge;
	private var _buttonGroup:LayoutGroup;
	private var _setButton:Button;
	private var _clearButton:Button;
	
	private var _fileSelector:FileSelectorDesktop = new FileSelectorDesktop();
	
	private var _action:MultiAction;
	private var _valueChangeAction:ValueChange;

	public function new() 
	{
		super();
		initializeNow();
	}
	
	override public function clear():Void 
	{
		if (this._action != null)
		{
			this._action.pool();
			this._action = null;
			this._valueChangeAction = null;
		}
		
		super.clear();
		this._filePathValue = null;
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
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
		
		this._pathInput = new TextInput();
		//this._pathInput.restrict = "a-Z A-Z 0-9 /\\:_-.";
		this._pathInput.layoutData = new HorizontalLayoutData(100);
		this._mainGroup.addChild(this._pathInput);
		
		this._controlGroup = new LayoutGroup();
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.TOP;
		hLayout.gap = Spacing.DEFAULT;
		this._controlGroup.layout = hLayout;
		addChild(this._controlGroup);
		
		this._wedge = new ValueWedge();
		this._controlGroup.addChild(this._wedge);
		
		this._buttonGroup = new LayoutGroup();
		this._buttonGroup.layoutData = new HorizontalLayoutData(100);
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.MINIMAL;
		this._buttonGroup.layout = vLayout;
		this._controlGroup.addChild(this._buttonGroup);
		
		this._setButton = new Button("set");
		this._buttonGroup.addChild(this._setButton);
		
		this._clearButton = new Button("clear");
	}
	
	override public function initExposedValue():Void 
	{
		super.initExposedValue();
		
		this._label.text = this._exposedValue.name;
		
		if (this._readOnly)
		{
			if (this._buttonGroup.parent != null) this._controlGroup.removeChild(this._buttonGroup);
		}
		else
		{
			if (this._buttonGroup.parent == null) this._controlGroup.addChild(this._buttonGroup);
		}
		
		if (this._clearButton.parent != null) this._buttonGroup.removeChild(this._clearButton);
		if (this._exposedValue.isNullable && !this._readOnly)
		{
			this._buttonGroup.addChild(this._clearButton);
		}
		
		updateEditable();
	}
	
	override public function updateExposedValue(exceptControl:IValueUI = null):Void 
	{
		super.updateExposedValue(exceptControl);
		
		if (this._initialized && this._exposedValue != null)
		{
			this._pathInput.text = this._exposedValue.value;
		}
	}
	
	private function updateEditable():Void
	{
		this.enabled = this._exposedValue.isEditable;
		this._label.enabled = this._exposedValue.isEditable;
		this._pathInput.enabled = this._exposedValue.isEditable;
		this._setButton.enabled = !this._readOnly && this._exposedValue.isEditable;
		this._clearButton.enabled = !this._readOnly && this._exposedValue.isEditable;
	}
	
	override function onValueEditableChange(evt:ValueEvent):Void 
	{
		super.onValueEditableChange(evt);
		updateEditable();
	}
	
	override function controlsDisable():Void 
	{
		if (this._readOnly) return;
		if (!this._controlsEnabled) return;
		super.controlsDisable();
		this._pathInput.removeEventListener(Event.CHANGE, onPathInputChange);
		this._setButton.removeEventListener(TriggerEvent.TRIGGER, onSetButton);
		this._clearButton.removeEventListener(TriggerEvent.TRIGGER, onClearButton);
		
		this._pathInput.removeEventListener(FocusEvent.FOCUS_IN, input_focusInHandler);
		this._pathInput.removeEventListener(FocusEvent.FOCUS_OUT, input_focusOutHandler);
	}
	
	override function controlsEnable():Void 
	{
		if (this._readOnly) return;
		if (this._controlsEnabled) return;
		super.controlsEnable();
		this._pathInput.addEventListener(Event.CHANGE, onPathInputChange);
		this._setButton.addEventListener(TriggerEvent.TRIGGER, onSetButton);
		this._clearButton.addEventListener(TriggerEvent.TRIGGER, onClearButton);
		
		this._pathInput.addEventListener(FocusEvent.FOCUS_IN, input_focusInHandler);
		this._pathInput.addEventListener(FocusEvent.FOCUS_OUT, input_focusOutHandler);
	}
	
	private function onClearButton(evt:TriggerEvent):Void
	{
		if (!this._exposedValue.isConstructor)
		{
			if (this._exposedValue.value != null)
			{
				var action:MultiAction = MultiAction.fromPool();
				
				var valueChange:ValueChange = ValueChange.fromPool();
				valueChange.setup(this._exposedValue, null);
				action.add(valueChange);
				
				var valueUIUpdate:ValueUIUpdate = ValueUIUpdate.fromPool();
				valueUIUpdate.setup(this._exposedValue);
				action.addPost(valueUIUpdate);
				
				ValEditor.actionStack.add(action);
			}
		}
		else
		{
			this._exposedValue.value = null;
		}
	}
	
	private function onSetButton(evt:TriggerEvent):Void
	{
		this._fileSelector.start(this.onFileSelected, this.onFileCancelled, this._filePathValue.fileMustExist, this._exposedValue.value, this._filePathValue.fileFilters, this._filePathValue.dialogTitle);
	}
	
	private function onFileSelected(path:String):Void
	{
		if (!this._exposedValue.isConstructor)
		{
			if (this._exposedValue.value != path)
			{
				var action:MultiAction = MultiAction.fromPool();
				
				var valueChange:ValueChange = ValueChange.fromPool();
				valueChange.setup(this._exposedValue, path);
				action.add(valueChange);
				
				var valueUIUpdate:ValueUIUpdate = ValueUIUpdate.fromPool();
				valueUIUpdate.setup(this._exposedValue);
				action.addPost(valueUIUpdate);
				
				ValEditor.actionStack.add(action);
			}
		}
		else
		{
			this._exposedValue.value = path;
			this._pathInput.text = path;
		}
	}
	
	private function onFileCancelled():Void
	{
		
	}
	
	private function onPathInputChange(evt:Event):Void
	{
		this._exposedValue.value = this._pathInput.text;
	}
	
	private function onValueChangeBegin(evt:ValueUIEvent):Void
	{
		if (this._exposedValue.isConstructor) return;
		
		if (this._action != null)
		{
			throw new Error("FilePathUI ::: action should be null");
		}
		
		this._action = MultiAction.fromPool();
		
		this._valueChangeAction = ValueChange.fromPool();
		this._valueChangeAction.setup(this._exposedValue, this._exposedValue.value, this._exposedValue.value);
		this._action.add(this._valueChangeAction);
		
		var valueUIUpdate:ValueUIUpdate = ValueUIUpdate.fromPool();
		valueUIUpdate.setup(this._exposedValue);
		this._action.addPost(valueUIUpdate);
	}
	
	private function onValueChangeEnd(evt:ValueUIEvent):Void
	{
		if (this._exposedValue.isConstructor) return;
		
		if (this._action == null)
		{
			throw new Error("FilePathUI ::: action should not be null");
		}
		
		this._valueChangeAction.newValue = this._exposedValue.value;
		if (this._valueChangeAction.newValue == this._valueChangeAction.previousValue)
		{
			this._action.pool();
		}
		else
		{
			ValEditor.actionStack.add(this._action);
		}
		this._action = null;
		this._valueChangeAction = null;
	}
	
	private function input_focusInHandler(evt:FocusEvent):Void
	{
		onValueChangeBegin(null);
	}
	
	private function input_focusOutHandler(evt:FocusEvent):Void
	{
		onValueChangeEnd(null);
	}
	
}
#end