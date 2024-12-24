package valeditor.ui.feathers.controls.value;
import feathers.controls.Button;
import feathers.controls.ComboBox;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.data.ArrayCollection;
import feathers.events.ListViewEvent;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalListLayout;
import haxe.ds.ObjectMap;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import valedit.events.ValueEvent;
import valedit.ui.IValueUI;
import valedit.value.ExposedSelectCombo;
import valedit.value.base.ExposedValue;
import valeditor.editor.action.MultiAction;
import valeditor.editor.action.value.ValueChange;
import valeditor.editor.action.value.ValueUIUpdate;
import valeditor.ui.feathers.Padding;
import valeditor.ui.feathers.Spacing;
import valeditor.ui.feathers.controls.ValueWedge;
import valeditor.ui.feathers.controls.value.base.ValueUI;
import valeditor.ui.feathers.theme.variant.LabelVariant;

/**
 * ...
 * @author Matse
 */
class SelectComboUI extends ValueUI 
{
	static private var _POOL:Array<SelectComboUI> = new Array<SelectComboUI>();
	
	static public function disposePool():Void
	{
		_POOL.resize(0);
	}
	
	static public function fromPool():SelectComboUI
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new SelectComboUI();
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
	
	private var _combo:ExposedSelectCombo;
	
	private var _mainGroup:LayoutGroup;
	private var _label:Label;
	private var _listLayout:VerticalListLayout;
	private var _list:ComboBox;
	
	private var _nullGroup:LayoutGroup;
	private var _wedge:ValueWedge;
	private var _nullButton:Button;
	
	private var _collection:ArrayCollection<Dynamic> = new ArrayCollection<Dynamic>();
	private var _valueToItem:ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();

	public function new() 
	{
		super();
		initializeNow();
	}
	
	override public function clear():Void 
	{
		super.clear();
		this._collection.removeAll();
		this._valueToItem.clear();
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
		
		this._listLayout = new VerticalListLayout();
		
		this._list = new ComboBox(this._collection);
		this._list.layoutData = new HorizontalLayoutData(100);
		this._list.itemToText = function(item:Dynamic):String { return item.text; }
		this._list.listViewFactory = () ->
		{
			var lv:ListView = new ListView();
			lv.layout = this._listLayout;
			lv.addEventListener(KeyboardEvent.KEY_DOWN, onListKeyboardEvent);
			lv.addEventListener(KeyboardEvent.KEY_UP, onListKeyboardEvent);
			lv.addEventListener(MouseEvent.CLICK, onListMouseClick);
			lv.addEventListener(MouseEvent.DOUBLE_CLICK, onListMouseEvent);
			lv.addEventListener(MouseEvent.MIDDLE_CLICK, onListMouseEvent);
			lv.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, onListMouseEvent);
			lv.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, onListMouseEvent);
			lv.addEventListener(MouseEvent.MOUSE_DOWN, onListMouseEvent);
			lv.addEventListener(MouseEvent.MOUSE_UP, onListMouseEvent);
			lv.addEventListener(MouseEvent.MOUSE_WHEEL, onListMouseEvent);
			lv.addEventListener(MouseEvent.RIGHT_CLICK, onListMouseEvent);
			lv.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onListMouseEvent);
			lv.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onListMouseEvent);
			return lv;
		};
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
		
		this._label.toolTip = this._exposedValue.toolTip;
		
		this._label.text = this._exposedValue.name;
		
		this._listLayout.contentJustify = this._combo.contentJustify;
		this._listLayout.requestedMaxRowCount = this._combo.requestedMaxRowCount;
		this._listLayout.requestedMinRowCount = this._combo.requestedMinRowCount;
		
		cast(this._list.layoutData, HorizontalLayoutData).percentWidth = this._combo.listPercentWidth;
		
		this._collection.removeAll();
		this._valueToItem.clear();
		var item:Dynamic;
		var count:Int = this._combo.choiceList.length;
		for (i in 0...count)
		{
			item = {text:this._combo.choiceList[i], value:this._combo.valueList[i]};
			this._collection.add(item);
			this._valueToItem.set(this._combo.valueList[i], item);
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
			//this._list.selectedIndex = this._combo.valueList.indexOf(this._exposedValue.value);
			this._list.selectedItem = this._valueToItem.get(this._exposedValue.value);
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
		this._list.removeEventListener(Event.CLOSE, onListClose);
		this._list.removeEventListener(ListViewEvent.ITEM_TRIGGER, onListItemTrigger);
		this._list.removeEventListener(KeyboardEvent.KEY_DOWN, onListKeyboardEvent);
		this._list.removeEventListener(KeyboardEvent.KEY_UP, onListKeyboardEvent);
		this._nullButton.removeEventListener(TriggerEvent.TRIGGER, onNullButton);
	}
	
	override function controlsEnable():Void 
	{
		if (this._readOnly) return;
		if (this._controlsEnabled) return;
		super.controlsEnable();
		this._list.addEventListener(Event.CHANGE, onListChange);
		this._list.addEventListener(Event.CLOSE, onListClose);
		this._list.addEventListener(ListViewEvent.ITEM_TRIGGER, onListItemTrigger);
		this._list.addEventListener(KeyboardEvent.KEY_DOWN, onListKeyboardEvent);
		this._list.addEventListener(KeyboardEvent.KEY_UP, onListKeyboardEvent);
		this._nullButton.addEventListener(TriggerEvent.TRIGGER, onNullButton);
	}
	
	private function onListChange(evt:Event):Void
	{
		if (!this._combo.selectOnKeyboardNavigation && this._list.open) return;
		
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
	
	private function onListClose(evt:Event):Void
	{
		var value:Dynamic = this._exposedValue.value;
		if ((this._list.selectedItem == null && value != null) || (this._list.selectedItem != null && this._list.selectedItem.value != value))
		{
			for (item in this._collection)
			{
				if (item.value == value)
				{
					this._list.selectedItem = item;
					break;
				}
			}
		}
	}
	
	private function onListItemTrigger(evt:ListViewEvent):Void
	{
		if (this._exposedValue.useActions)
		{
			if (this._exposedValue.value != evt.state.data.value)
			{
				var action:MultiAction = MultiAction.fromPool();
				
				var valueChange:ValueChange = ValueChange.fromPool();
				valueChange.setup(this._exposedValue, evt.state.data.value);
				action.add(valueChange);
				
				var valueUIUpdate:ValueUIUpdate = ValueUIUpdate.fromPool();
				valueUIUpdate.setup(this._exposedValue);
				action.addPost(valueUIUpdate);
				
				ValEditor.actionStack.add(action);
			}
		}
		else
		{
			this._exposedValue.value = evt.state.data.value;
		}
	}
	
	private function onListKeyboardEvent(evt:KeyboardEvent):Void
	{
		evt.stopPropagation();
	}
	
	private function onListMouseClick(evt:MouseEvent):Void
	{
		if (this.focusManager != null)
		{
			this.focusManager.focus = null;
		}
		else if (this.stage != null)
		{
			this.stage.focus = null;
		}
		
		evt.stopPropagation();
	}
	
	private function onListMouseEvent(evt:MouseEvent):Void
	{
		evt.stopPropagation();
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