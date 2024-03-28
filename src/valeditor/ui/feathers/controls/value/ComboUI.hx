package valeditor.ui.feathers.controls.value;
import feathers.controls.Button;
import feathers.controls.ComboBox;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.data.ArrayCollection;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import valeditor.editor.action.MultiAction;
import valeditor.editor.action.value.ValueChange;
import valeditor.editor.action.value.ValueUIUpdate;
import valeditor.ui.feathers.Padding;
import valeditor.ui.feathers.Spacing;
import valeditor.ui.feathers.controls.ValueWedge;
import valeditor.ui.feathers.controls.value.base.ValueUI;
import valeditor.ui.feathers.variant.LabelVariant;
import valedit.value.base.ExposedValue;
import valedit.events.ValueEvent;
import valedit.ui.IValueUI;
import valedit.value.ExposedCombo;

/**
 * ...
 * @author Matse
 */
class ComboUI extends ValueUI 
{
	static private var _POOL:Array<ComboUI> = new Array<ComboUI>();
	
	static public function disposePool():Void
	{
		_POOL.resize(0);
	}
	
	static public function fromPool():ComboUI
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ComboUI();
	}
	
	override function set_exposedValue(value:ExposedValue):ExposedValue 
	{
		if (value == null)
		{
			this._combo = null;
		}
		else
		{
			this._combo = cast value;
		}
		return super.set_exposedValue(value);
	}
	
	private var _combo:ExposedCombo;
	
	private var _mainGroup:LayoutGroup;
	private var _label:Label;
	private var _list:ComboBox;
	
	private var _nullGroup:LayoutGroup;
	private var _wedge:ValueWedge;
	private var _nullButton:Button;
	
	private var _collection:ArrayCollection<Dynamic> = new ArrayCollection<Dynamic>();

	public function new() 
	{
		super();
		initializeNow();
	}
	
	override public function clear():Void 
	{
		super.clear();
		this._combo = null;
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
		vLayout.paddingRight = Padding.VALUE;
		this.layout = vLayout;
		
		this._mainGroup = new LayoutGroup();
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.gap = Spacing.DEFAULT;
		hLayout.paddingRight = Padding.VALUE;
		this._mainGroup.layout = hLayout;
		addChild(this._mainGroup);
		
		this._label = new Label();
		this._label.variant = LabelVariant.VALUE_NAME;
		this._mainGroup.addChild(this._label);
		
		this._list = new ComboBox(this._collection);
		this._list.layoutData = new HorizontalLayoutData(100);
		this._list.itemToText = function(item:Dynamic):String { return item.text; }
		this._mainGroup.addChild(this._list);
		
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
		this._list.enabled = !this._readOnly;
		this._collection.removeAll();
		var count:Int = this._combo.choiceList.length;
		for (i in 0...count)
		{
			_collection.add({text:this._combo.choiceList[i], value:this._combo.valueList[i]});
		}
		
		if (this._nullGroup.parent != null) removeChild(this._nullGroup);
		if (this._exposedValue.isNullable && !this._readOnly)
		{
			addChild(this._nullGroup);
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
			this._list.selectedIndex = this._combo.valueList.indexOf(this._exposedValue.value);
			if (controlsEnabled) controlsEnable();
		}
	}
	
	private function updateEditable():Void
	{
		this.enabled = this._exposedValue.isEditable;
		this._label.enabled = this._exposedValue.isEditable;
		this._list.enabled = !this._readOnly && this._exposedValue.isEditable;
		this._nullButton.enabled = !this._readOnly && this._exposedValue.isEditable;
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
		this._list.removeEventListener(Event.CHANGE, onListChange);
		this._list.removeEventListener(KeyboardEvent.KEY_DOWN, onComboKeyDown);
		this._list.removeEventListener(KeyboardEvent.KEY_UP, onComboKeyUp);
		this._nullButton.removeEventListener(TriggerEvent.TRIGGER, onNullButton);
	}
	
	override function controlsEnable():Void 
	{
		if (this._readOnly) return;
		if (this._controlsEnabled) return;
		super.controlsEnable();
		this._list.addEventListener(Event.CHANGE, onListChange);
		this._list.addEventListener(KeyboardEvent.KEY_DOWN, onComboKeyDown);
		this._list.addEventListener(KeyboardEvent.KEY_UP, onComboKeyUp);
		this._nullButton.addEventListener(TriggerEvent.TRIGGER, onNullButton);
	}
	
	private function onComboKeyDown(evt:KeyboardEvent):Void
	{
		evt.stopPropagation();
	}
	
	private function onComboKeyUp(evt:KeyboardEvent):Void
	{
		evt.stopPropagation();
	}
	
	private function onListChange(evt:Event):Void
	{
		if (this._list.selectedItem == null) return;
		
		if (this._exposedValue.useActions)
		{
			if (this._exposedValue.value != this._list.selectedItem.value)
			{
				var action:MultiAction = MultiAction.fromPool();
				
				var valueChange:ValueChange = ValueChange.fromPool();
				valueChange.setup(this._exposedValue, this._list.selectedItem.value);
				action.add(valueChange);
				
				var valueUIUpdate:ValueUIUpdate = ValueUIUpdate.fromPool();
				valueUIUpdate.setup(this._exposedValue);
				action.addPost(valueUIUpdate);
				
				ValEditor.actionStack.add(action);
			}
		}
		else
		{
			this._exposedValue.value = this._list.selectedItem.value;
		}
	}
	
	private function onNullButton(evt:TriggerEvent):Void
	{
		if (this._exposedValue.useActions)
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
			this._list.selectedIndex = -1;
		}
	}
	
}