package valeditor.ui.feathers.controls.value;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import valeditor.editor.action.MultiAction;
import valeditor.editor.action.value.ValueChange;
import valeditor.editor.action.value.ValueUIUpdate;
import valeditor.ui.feathers.FeathersWindows;
import valeditor.ui.feathers.Padding;
import valeditor.ui.feathers.Spacing;
import valeditor.ui.feathers.controls.value.base.ValueUI;
import valeditor.ui.feathers.theme.variant.LabelVariant;
import valedit.asset.TextAsset;
import valedit.ui.IValueUI;

/**
 * ...
 * @author Matse
 */
class TextAssetUI extends ValueUI 
{
	static private var _POOL:Array<TextAssetUI> = new Array<TextAssetUI>();
	
	static public function disposePool():Void
	{
		_POOL.resize(0);
	}
	
	static public function fromPool():TextAssetUI
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TextAssetUI();
	}
	
	private var _label:Label;
	
	private var _contentGroup:LayoutGroup;
	
	private var _nameLabel:Label;
	private var _pathLabel:Label;
	
	private var _buttonGroup:LayoutGroup;
	private var _loadButton:Button;
	private var _clearButton:Button;

	public function new() 
	{
		super();
		initializeNow();
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
		
		this._nameLabel = new Label();
		this._contentGroup.addChild(this._nameLabel);
		
		this._pathLabel = new Label();
		this._pathLabel.wordWrap = true;
		this._contentGroup.addChild(this._pathLabel);
		
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
		//this._buttonGroup.addChild(this._clearButton);
	}
	
	override public function initExposedValue():Void 
	{
		super.initExposedValue();
		
		this._label.toolTip = this._exposedValue.toolTip;
		
		this._label.text = this._exposedValue.name;
		
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
			var controlsEnabled:Bool = this._controlsEnabled;
			if (controlsEnabled) controlsDisable();
			var value:TextAsset = this._exposedValue.value;
			assetUpdate(value);
			if (controlsEnabled) controlsEnable();
		}
	}
	
	override function updateEditable():Void 
	{
		super.updateEditable();
		
		var enabled:Bool = this._exposedValue.isEditable && !this._exposedValue.isReadOnly;
		
		this.enabled = enabled;
		this._label.enabled = enabled;
		this._pathLabel.enabled = enabled;
		this._loadButton.enabled = enabled;
		this._clearButton.enabled = enabled;
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
			assetUpdate(null);
		}
	}
	
	private function onLoadButton(evt:TriggerEvent):Void
	{
		FeathersWindows.showTextAssets(assetSelected, null, "Select Text asset");
	}
	
	private function assetSelected(asset:TextAsset):Void
	{
		if (this._exposedValue.useActions)
		{
			if (this._exposedValue.value != asset)
			{
				var action:MultiAction = MultiAction.fromPool();
				
				var valueChange:ValueChange = ValueChange.fromPool();
				valueChange.setup(this._exposedValue, asset);
				action.add(valueChange);
				
				var valueUIUpdate:ValueUIUpdate = ValueUIUpdate.fromPool();
				valueUIUpdate.setup(this._exposedValue);
				action.addPost(valueUIUpdate);
				
				ValEditor.actionStack.add(action);
			}
		}
		else
		{
			this._exposedValue.value = asset;
			assetUpdate(asset);
		}
	}
	
	private function assetUpdate(asset:TextAsset):Void
	{
		if (asset == null)
		{
			this._nameLabel.text = "";
			this._pathLabel.text = "";
		}
		else
		{
			this._nameLabel.text = asset.name;
			this._pathLabel.text = asset.path;
		}
	}
	
}