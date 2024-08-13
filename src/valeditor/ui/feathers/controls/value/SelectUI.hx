package valeditor.ui.feathers.controls.value;

import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.controls.PopUpListView;
import feathers.data.ArrayCollection;
import feathers.events.ListViewEvent;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import valeditor.editor.action.MultiAction;
import valeditor.editor.action.value.ValueChange;
import valeditor.editor.action.value.ValueUIUpdate;
import valeditor.ui.feathers.controls.ValueWedge;
import valeditor.ui.feathers.controls.value.base.ValueUI;
import valeditor.ui.feathers.theme.variant.LabelVariant;
import valedit.value.base.ExposedValue;
import valedit.events.ValueEvent;
import valedit.ui.IValueUI;
import valedit.value.ExposedSelect;
import valeditor.ui.feathers.Padding;
import valeditor.ui.feathers.Spacing;

/**
 * ...
 * @author Matse
 */
class SelectUI extends ValueUI 
{
	static private var _POOL:Array<SelectUI> = new Array<SelectUI>();
	
	static public function disposePool():Void
	{
		_POOL.resize(0);
	}
	
	static public function fromPool():SelectUI
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new SelectUI();
	}
	
	override function set_exposedValue(value:ExposedValue):ExposedValue 
	{
		if (value == null)
		{
			this._select = null;
		}
		else
		{
			this._select = cast value;
		}
		return super.set_exposedValue(value);
	}
	
	private var _select:ExposedSelect;
	
	private var _mainGroup:LayoutGroup;
	private var _label:Label;
	private var _list:PopUpListView;
	private var _collection:ArrayCollection<Dynamic> = new ArrayCollection<Dynamic>();
	
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
	
	override public function clear():Void 
	{
		super.clear();
		this._select = null;
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
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.gap = Spacing.DEFAULT;
		this._mainGroup.layout = hLayout;
		addChild(this._mainGroup);
		
		this._label = new Label();
		this._label.variant = LabelVariant.VALUE_NAME;
		this._mainGroup.addChild(this._label);
		
		this._list = new PopUpListView(this._collection);
		this._list.layoutData = new HorizontalLayoutData(100);
		this._list.itemToText = function(item:Dynamic):String { return item.text; };
		this._list.listViewFactory = () ->
		{
			var lv:ListView = new ListView();
			lv.addEventListener(KeyboardEvent.KEY_DOWN, onListKeyDown);
			lv.addEventListener(KeyboardEvent.KEY_UP, onListKeyUp);
			lv.addEventListener(MouseEvent.CLICK, onListMouseClick);
			return lv;
		};
		this._mainGroup.addChild(this._list);
		
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
		
		this._label.toolTip = this._exposedValue.toolTip;
		
		this._label.text = this._exposedValue.name;
		
		cast(this._list.layoutData, HorizontalLayoutData).percentWidth = this._select.listPercentWidth;
		
		this._collection.removeAll();
		var count:Int = this._select.choiceList.length;
		for (i in 0...count)
		{
			this._collection.add({text:this._select.choiceList[i], value:this._select.valueList[i]});
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
			this._list.selectedIndex = this._select.valueList.indexOf(this._exposedValue.value);
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
		this._list.removeEventListener(KeyboardEvent.KEY_DOWN, onListKeyDown);
		this._list.removeEventListener(KeyboardEvent.KEY_UP, onListKeyUp);
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
		this._list.addEventListener(KeyboardEvent.KEY_DOWN, onListKeyDown);
		this._list.addEventListener(KeyboardEvent.KEY_UP, onListKeyUp);
		this._nullButton.addEventListener(TriggerEvent.TRIGGER, onNullButton);
	}
	
	private function onListChange(evt:Event):Void
	{
		if (!this._select.selectOnKeyboardNavigation && this._list.open) return;
		
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
	
	private function onListKeyDown(evt:KeyboardEvent):Void
	{
		evt.stopPropagation();
	}
	
	private function onListKeyUp(evt:KeyboardEvent):Void
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