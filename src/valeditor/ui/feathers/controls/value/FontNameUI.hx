package valeditor.ui.feathers.controls.value;
import feathers.controls.Button;
import feathers.controls.ComboBox;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.data.ArrayCollection;
import feathers.events.ListViewEvent;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import openfl.errors.Error;
import openfl.text.Font;
import openfl.text.FontType;
import valedit.events.ValueEvent;
import valedit.ui.IValueUI;
import valedit.value.ExposedFontName;
import valedit.value.base.ExposedValue;
import valedit.value.data.FontSelection;
import valeditor.editor.action.MultiAction;
import valeditor.editor.action.value.ValueChange;
import valeditor.editor.action.value.ValueUIUpdate;
import valeditor.ui.feathers.Padding;
import valeditor.ui.feathers.Spacing;
import valeditor.ui.feathers.controls.ValueWedge;
import valeditor.ui.feathers.controls.value.base.ValueUI;
import valeditor.ui.feathers.data.FontData;
import valeditor.ui.feathers.variant.LabelVariant;

/**
 * ...
 * @author Matse
 */
class FontNameUI extends ValueUI 
{
	static private var FONT_DATA_INITIALIZED:Bool = false;
	
	static private var FONT_DATA_LIST_ALL:Array<FontData> = new Array<FontData>();
	static private var FONT_DATA_LIST_EMBEDDED:Array<FontData> = new Array<FontData>();
	static private var FONT_DATA_LIST_SYSTEM:Array<FontData> = new Array<FontData>();
	
	static private var FONT_DATA_COLLECTION_ALL:ArrayCollection<FontData> = new ArrayCollection<FontData>(FONT_DATA_LIST_ALL);
	static private var FONT_DATA_COLLECTION_EMBEDDED:ArrayCollection<FontData> = new ArrayCollection<FontData>(FONT_DATA_LIST_EMBEDDED);
	static private var FONT_DATA_COLLECTION_SYSTEM:ArrayCollection<FontData> = new ArrayCollection<FontData>(FONT_DATA_LIST_SYSTEM);
	
	static private var DISPLAY_NAME_TO_FONT_DATA:Map<String, FontData> = new Map<String, FontData>();
	static private var FONT_NAME_TO_FONT_DATA:Map<String, FontData> = new Map<String, FontData>();
	
	static private function clearFontData():Void
	{
		FontData.poolArray(FONT_DATA_LIST_ALL);
		FONT_DATA_LIST_ALL.resize(0);
		FONT_DATA_LIST_EMBEDDED.resize(0);
		FONT_DATA_LIST_SYSTEM.resize(0);
		
		DISPLAY_NAME_TO_FONT_DATA.clear();
		FONT_NAME_TO_FONT_DATA.clear();
		
		FONT_DATA_INITIALIZED = false;
	}
	
	static private function initFontData():Void
	{
		if (FONT_DATA_INITIALIZED)
		{
			clearFontData();
		}
		
		var data:FontData;
		data = FontData.fromPool("_sans (generic)", "_sans", FontType.DEVICE);
		registerFontData(data);
		data = FontData.fromPool("_serif (generic)", "_serif", FontType.DEVICE);
		registerFontData(data);
		data = FontData.fromPool("_typewriter (generic)", "_typewriter", FontType.DEVICE);
		
		var fonts:Array<Font> = Font.enumerateFonts(true);
		for (font in fonts)
		{
			#if neko
			// on my PC on neko target I get a bunch of "null" entries in the list returned by Font.enumerateFonts
			if (font == null) continue;
			#end
			if (font.fontType == FontType.DEVICE)
			{
				data = FontData.fromPool(font.fontName, font.fontName, font.fontType);
			}
			else
			{
				data = FontData.fromPool(font.fontName + "*", font.fontName, font.fontType);
			}
			registerFontData(data);
		}
		
		FONT_DATA_INITIALIZED = true;
	}
	
	static private function registerFontData(data:FontData):Void
	{
		FONT_DATA_LIST_ALL[FONT_DATA_LIST_ALL.length] = data;
		if (data.fontType == FontType.DEVICE)
		{
			FONT_DATA_LIST_SYSTEM[FONT_DATA_LIST_SYSTEM.length] = data;
		}
		else
		{
			FONT_DATA_LIST_EMBEDDED[FONT_DATA_LIST_EMBEDDED.length] = data;
		}
		
		DISPLAY_NAME_TO_FONT_DATA.set(data.displayName, data);
		FONT_NAME_TO_FONT_DATA.set(data.fontName, data);
	}
	
	static private var _POOL:Array<FontNameUI> = new Array<FontNameUI>();
	
	static public function disposePool():Void
	{
		_POOL.resize(0);
	}
	
	static public function fromPool():FontNameUI
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new FontNameUI();
	}
	
	override function set_exposedValue(value:ExposedValue):ExposedValue 
	{
		if (value == null)
		{
			this._fontName = null;
		}
		else
		{
			this._fontName = cast value;
		}
		return super.set_exposedValue(value);
	}
	
	private var _fontName:ExposedFontName;
	
	private var _mainGroup:LayoutGroup;
	private var _label:Label;
	private var _list:ComboBox;
	
	private var _nullGroup:LayoutGroup;
	private var _wedge:ValueWedge;
	private var _nullButton:Button;

	public function new() 
	{
		super();
		initializeNow();
	}
	
	override public function clear():Void 
	{
		this._fontName = null;
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var vLayout:VerticalLayout;
		var hLayout:HorizontalLayout;
		
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
		
		this._list = new ComboBox();
		this._list.layoutData = new HorizontalLayoutData(100);
		this._list.itemToText = function(item:Dynamic):String {
			return item.displayName;
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
		
		this._label.text = this._exposedValue.name;
		
		if (!FONT_DATA_INITIALIZED)
		{
			initFontData();
		}
		
		switch (this._fontName.fontSelection)
		{
			case FontSelection.ALL :
				this._list.dataProvider = FONT_DATA_COLLECTION_ALL;
			
			case FontSelection.CUSTOM :
				throw new Error("FontNameUI ::: FontSelection.CUSTOM not supported yet");
			
			case FontSelection.EMBEDDED :
				this._list.dataProvider = FONT_DATA_COLLECTION_EMBEDDED;
			
			case FontSelection.SYSTEM :
				this._list.dataProvider = FONT_DATA_COLLECTION_SYSTEM;
		}
		
		this._list.enabled = !this._readOnly;
		
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
			var data:FontData = FONT_NAME_TO_FONT_DATA.get(this._exposedValue.value);
			this._list.selectedIndex = this._list.dataProvider.indexOf(data);
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
		this._list.removeEventListener(ListViewEvent.ITEM_TRIGGER, onListItemTrigger);
		this._nullButton.removeEventListener(TriggerEvent.TRIGGER, onNullButton);
	}
	
	override function controlsEnable():Void 
	{
		if (this._readOnly) return;
		if (this._controlsEnabled) return;
		super.controlsEnable();
		this._list.addEventListener(ListViewEvent.ITEM_TRIGGER, onListItemTrigger);
		this._nullButton.addEventListener(TriggerEvent.TRIGGER, onNullButton);
	}
	
	private function onListItemTrigger(evt:ListViewEvent):Void
	{
		var fontName:String = evt.state.data.fontName;
		
		if (!this._exposedValue.isConstructor)
		{
			if (this._exposedValue.value != fontName)
			{
				var action:MultiAction = MultiAction.fromPool();
				
				var valueChange:ValueChange = ValueChange.fromPool();
				valueChange.setup(this._exposedValue, fontName);
				action.add(valueChange);
				
				var valueUIUpdate:ValueUIUpdate = ValueUIUpdate.fromPool();
				valueUIUpdate.setup(this._exposedValue);
				action.addPost(valueUIUpdate);
				
				ValEditor.actionStack.add(action);
			}
		}
		else
		{
			this._exposedValue.value = fontName;
		}
	}
	
	private function onNullButton(evt:TriggerEvent):Void
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
			this._list.selectedIndex = -1;
		}
	}
	
}