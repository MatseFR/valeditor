package valeditor.ui.feathers.controls.value;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.controls.PopUpListView;
import feathers.data.ArrayCollection;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import valedit.value.base.ExposedValue;
import valedit.ValEditObject;
import valedit.events.ValueEvent;
import valedit.ui.IValueUI;
import valedit.value.ExposedObjectReference;
import valedit.value.reference.ReferenceRange;
import valeditor.ValEditorObject;
import valeditor.editor.action.MultiAction;
import valeditor.editor.action.value.ReferenceRangeChange;
import valeditor.editor.action.value.ValueChange;
import valeditor.editor.action.value.ValueUIUpdate;
import valeditor.ui.feathers.FeathersWindows;
import valeditor.ui.feathers.Spacing;
import valeditor.ui.feathers.controls.value.base.ValueUI;
import valeditor.ui.feathers.theme.variant.LabelVariant;

/**
 * ...
 * @author Matse
 */
@:access(valedit.value.ExposedObjectReference)
class ObjectReferenceUI extends ValueUI 
{
	static private var _POOL:Array<ObjectReferenceUI> = new Array<ObjectReferenceUI>();
	
	static public function disposePool():Void
	{
		_POOL.resize(0);
	}
	
	static public function fromPool():ObjectReferenceUI
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ObjectReferenceUI();
	}
	
	private var _objectReferenceValue:ExposedObjectReference;
	
	override function set_exposedValue(value:ExposedValue):ExposedValue 
	{
		if (value == null)
		{
			this._objectReferenceValue = null;
		}
		else
		{
			this._objectReferenceValue = cast value;
		}
		return super.set_exposedValue(value);
	}
	
	private var _label:Label;
	
	private var _contentGroup:LayoutGroup;
	
	private var _idLabel:Label;
	
	private var _rangeList:PopUpListView;
	private var _rangeCollection:ArrayCollection<Dynamic> = new ArrayCollection<Dynamic>();
	
	private var _buttonGroup:LayoutGroup;
	private var _loadButton:Button;
	private var _clearButton:Button;
	
	public function new() 
	{
		super();
		initializeNow();
	}
	
	override public function clear():Void 
	{
		super.clear();
		this._objectReferenceValue = null;
		this._rangeCollection.removeAll();
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
		
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.TOP;
		hLayout.gap = Spacing.DEFAULT;
		hLayout.paddingRight = Padding.VALUE;
		this.layout = hLayout;
		
		this._label = new Label();
		this._label.variant = LabelVariant.VALUE_NAME;
		addChild(this._label);
		
		this._contentGroup = new LayoutGroup();
		this._contentGroup.layoutData = new HorizontalLayoutData(100);
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.VERTICAL_GAP;
		this._contentGroup.layout = vLayout;
		addChild(this._contentGroup);
		
		this._idLabel = new Label();
		this._contentGroup.addChild(this._idLabel);
		
		this._rangeList = new PopUpListView(this._rangeCollection);
		//this._list.layoutData = new HorizontalLayoutData(100);
		this._rangeList.itemToText = function(item:Dynamic):String { return item.text; };
		this._rangeList.listViewFactory = () ->
		{
			var lv:ListView = new ListView();
			lv.addEventListener(KeyboardEvent.KEY_DOWN, onListKeyDown);
			lv.addEventListener(KeyboardEvent.KEY_UP, onListKeyUp);
			lv.addEventListener(MouseEvent.CLICK, onListMouseClick);
			return lv;
		};
		this._rangeList.addEventListener(Event.CHANGE, onRangeListChange);
		this._contentGroup.addChild(this._rangeList);
		
		this._buttonGroup = new LayoutGroup();
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.TOP;
		this._buttonGroup.layout = hLayout;
		this._contentGroup.addChild(this._buttonGroup);
		
		this._loadButton = new Button("set");
		this._loadButton.layoutData = new HorizontalLayoutData(50);
		this._buttonGroup.addChild(this._loadButton);
		
		this._clearButton = new Button("clear");
		this._clearButton.layoutData = new HorizontalLayoutData(50);
		this._buttonGroup.addChild(this._clearButton);
	}
	
	override public function initExposedValue():Void 
	{
		super.initExposedValue();
		
		this._label.toolTip = this._exposedValue.toolTip;
		
		this._label.text = this._exposedValue.name;
		
		var count:Int = this._objectReferenceValue.allowedReferenceRanges.length;
		for (i in 0...count)
		{
			this._rangeCollection.add({text:this._objectReferenceValue.allowedReferenceRanges[i], value:this._objectReferenceValue.allowedReferenceRanges[i]});
		}
		
		if (this._readOnly)
		{
			if (this._buttonGroup.parent != null) this._contentGroup.removeChild(this._buttonGroup);
		}
		else
		{
			if (this._buttonGroup.parent == null) this._contentGroup.addChild(this._buttonGroup);
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
			var index:Int = this._objectReferenceValue.allowedReferenceRanges.indexOf(this._objectReferenceValue._referenceRange);
			this._rangeList.selectedIndex = index;
			
			var object:ValEditorObject = this._objectReferenceValue._valEditObjectReference;
			if (object != null)
			{
				this._idLabel.text = object.id;
			}
			else
			{
				this._idLabel.text = "";
			}
		}
	}
	
	private function updateEditable():Void
	{
		this.enabled = this._exposedValue.isEditable;
		this._label.enabled = this._exposedValue.isEditable;
		this._idLabel.enabled = this._exposedValue.isEditable;
		this._loadButton.enabled = !this._readOnly && this._exposedValue.isEditable;
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
		this._loadButton.removeEventListener(TriggerEvent.TRIGGER, onLoadButton);
		this._clearButton.removeEventListener(TriggerEvent.TRIGGER, onClearButton);
	}
	
	override function controlsEnable():Void 
	{
		if (this._readOnly) return;
		if (this._controlsEnabled) return;
		super.controlsEnable();
		this._loadButton.addEventListener(TriggerEvent.TRIGGER, onLoadButton);
		this._clearButton.addEventListener(TriggerEvent.TRIGGER, onClearButton);
	}
	
	private function onClearButton(evt:TriggerEvent):Void
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
			this._idLabel.text = "";
		}
	}
	
	private function onLoadButton(evt:TriggerEvent):Void
	{
		var excludeObjects:Array<ValEditorObject>;
		if (this._objectReferenceValue.allowSelfReference)
		{
			excludeObjects = null;
		}
		else
		{
			excludeObjects = [this._objectReferenceValue.valEditorObject];
		}
		var objectCollection:ArrayCollection<ValEditorObject>;
		switch (this._objectReferenceValue._referenceRange)
		{
			case ReferenceRange.CONTAINER :
				objectCollection = ValEditor.currentContainer.allObjectsCollection;
			
			case ReferenceRange.CONTAINER_LIBRARY :
				objectCollection = ValEditor.currentContainer.libraryObjectsCollection;
			
			default :
				throw new Error("unknown ReferenceRange : " + this._objectReferenceValue._referenceRange);
		}
		FeathersWindows.showObjectSelectWindow(objectCollection, objectSelected, null, this._objectReferenceValue.classList, excludeObjects);
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
	
	private function onRangeListChange(evt:Event):Void
	{
		var newReferenceRange:String;
		if (this._rangeList.selectedIndex == -1)
		{
			newReferenceRange = null;
			this._loadButton.enabled = false;
			this._clearButton.enabled = false;
		}
		else
		{
			newReferenceRange = this._objectReferenceValue.allowedReferenceRanges[this._rangeList.selectedIndex];
			this._loadButton.enabled = true;
			this._clearButton.enabled = true;
		}
		
		if (this._exposedValue != null)
		{
			if (this._exposedValue.useActions)
			{
				if (newReferenceRange != this._objectReferenceValue._referenceRange)
				{
					var action:MultiAction = MultiAction.fromPool();
					
					var referenceRangeChange:ReferenceRangeChange = ReferenceRangeChange.fromPool();
					referenceRangeChange.setup(this._objectReferenceValue, newReferenceRange);
					action.add(referenceRangeChange);
					
					var valueUIUpdate:ValueUIUpdate = ValueUIUpdate.fromPool();
					valueUIUpdate.setup(this._exposedValue);
					action.addPost(valueUIUpdate);
					
					ValEditor.actionStack.add(action);
				}
			}
			else
			{
				this._objectReferenceValue._referenceRange = newReferenceRange;
			}
		}
	}
	
	private function objectSelected(object:ValEditorObject):Void
	{
		if (this._exposedValue.useActions)
		{
			var action:MultiAction = MultiAction.fromPool();
			
			var valueChange:ValueChange = ValueChange.fromPool();
			valueChange.setup(this._exposedValue, object);
			action.add(valueChange);
			
			var valueUIUpdate:ValueUIUpdate = ValueUIUpdate.fromPool();
			valueUIUpdate.setup(this._exposedValue);
			action.addPost(valueUIUpdate);
			
			ValEditor.actionStack.add(action);
		}
		else
		{
			this._exposedValue.value = object;
			if (Std.isOfType(object, ValEditorObject))
			{
				this._idLabel.text = cast(object, ValEditorObject).id;
			}
			else
			{
				throw new Error("missing ValEditorObject");
			}
		}
	}
	
}