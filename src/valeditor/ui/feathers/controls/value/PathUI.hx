package valeditor.ui.feathers.controls.value;
import valedit.ExposedValue;
import valedit.value.ExposedPath;
import valeditor.utils.file.FolderSelectorDesktop;
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
import valedit.events.ValueEvent;
import valedit.ui.IValueUI;
import valeditor.ui.feathers.controls.ValueWedge;
import valeditor.ui.feathers.variant.LabelVariant;

/**
 * Desktop targets only (Neko, CPP, Air...)
 * @author Matse
 */
class PathUI extends ValueUI 
{
	override function set_exposedValue(value:ExposedValue):ExposedValue 
	{
		if (value == null)
		{
			this._pathValue = null;
		}
		else
		{
			this._pathValue = cast value;
		}
		return super.set_exposedValue(value);
	}
	
	private var _pathValue:ExposedPath;
	
	private var _mainGroup:LayoutGroup;
	private var _label:Label;
	private var _pathLabel:Label;
	
	private var _controlGroup:LayoutGroup;
	private var _wedge:ValueWedge;
	private var _buttonGroup:LayoutGroup;
	private var _setButton:Button;
	private var _clearButton:Button;
	
	private var _folderSelector:FolderSelectorDesktop = new FolderSelectorDesktop();

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
		
		this._pathLabel = new Label();
		this._pathLabel.variant = LabelVariant.VALUE;
		this._pathLabel.wordWrap = true;
		this._pathLabel.layoutData = new HorizontalLayoutData(100);
		this._mainGroup.addChild(this._pathLabel);
		
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
		
		if (this._exposedValue.isNullable)
		{
			if (this._clearButton.parent == null)
			{
				this._buttonGroup.addChild(this._clearButton);
			}
		}
		else
		{
			if (this._clearButton.parent != null)
			{
				this._buttonGroup.removeChild(this._clearButton);
			}
		}
		
		updateEditable();
	}
	
	override public function updateExposedValue(exceptControl:IValueUI = null):Void 
	{
		super.updateExposedValue(exceptControl);
		
		if (this._initialized && this._exposedValue != null)
		{
			this._pathLabel.text = this._exposedValue.value;
		}
	}
	
	private function updateEditable():Void
	{
		this.enabled = this._exposedValue.isEditable;
		this._label.enabled = this._exposedValue.isEditable;
		this._pathLabel.enabled = this._exposedValue.isEditable;
		this._setButton.enabled = this._exposedValue.isEditable;
		this._clearButton.enabled = this._exposedValue.isEditable;
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
		this._setButton.removeEventListener(TriggerEvent.TRIGGER, onSetButton);
		this._clearButton.removeEventListener(TriggerEvent.TRIGGER, onClearButton);
	}
	
	override function controlsEnable():Void 
	{
		if (this._controlsEnabled) return;
		super.controlsEnable();
		this._setButton.addEventListener(TriggerEvent.TRIGGER, onSetButton);
		this._clearButton.addEventListener(TriggerEvent.TRIGGER, onClearButton);
	}
	
	private function onClearButton(evt:TriggerEvent):Void
	{
		this._exposedValue.value = null;
	}
	
	private function onSetButton(evt:TriggerEvent):Void
	{
		this._folderSelector.start(this.onFolderSelected, this.onFolderCancelled, this._pathValue.dialogTitle);
	}
	
	private function onFolderSelected(path:String):Void
	{
		this._exposedValue.value = path;
	}
	
	private function onFolderCancelled():Void
	{
		
	}
	
}
#end