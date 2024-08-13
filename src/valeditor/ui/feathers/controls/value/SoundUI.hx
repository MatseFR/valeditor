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
import openfl.media.Sound;
import openfl.media.SoundChannel;
import valedit.ValEdit;
import valedit.asset.SoundAsset;
import valedit.events.ValueEvent;
import valedit.ui.IValueUI;
import valeditor.editor.action.MultiAction;
import valeditor.editor.action.value.ValueChange;
import valeditor.editor.action.value.ValueUIUpdate;
import valeditor.ui.feathers.FeathersWindows;
import valeditor.ui.feathers.Padding;
import valeditor.ui.feathers.Spacing;
import valeditor.ui.feathers.controls.value.base.ValueUI;
import valeditor.ui.feathers.theme.variant.LabelVariant;
import valeditor.utils.TimeUtil;

/**
 * ...
 * @author Matse
 */
class SoundUI extends ValueUI 
{
	static private var _POOL:Array<SoundUI> = new Array<SoundUI>();
	
	static public function disposePool():Void
	{
		_POOL.resize(0);
	}
	
	static public function fromPool():SoundUI
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new SoundUI();
	}
	
	private var _label:Label;
	
	private var _contentGroup:LayoutGroup;
	
	private var _nameLabel:Label;
	private var _pathLabel:Label;
	private var _durationLabel:Label;
	
	private var _buttonGroup:LayoutGroup;
	private var _loadButton:Button;
	private var _clearButton:Button;
	
	private var _playButton:Button;
	private var _stopButton:Button;
	
	private var _soundChannel:SoundChannel;

	public function new() 
	{
		super();
		initializeNow();
	}
	
	override public function clear():Void 
	{
		super.clear();
		if (this._soundChannel != null)
		{
			this._soundChannel.stop();
			this._soundChannel = null;
		}
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
		
		this._durationLabel = new Label();
		this._contentGroup.addChild(this._durationLabel);
		
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
		
		this._playButton = new Button("play");
		this._contentGroup.addChild(this._playButton);
		
		this._stopButton = new Button("stop");
		this._contentGroup.addChild(this._stopButton);
	}
	
	override public function initExposedValue():Void 
	{
		super.initExposedValue();
		
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
		
		this._label.toolTip = this._exposedValue.toolTip;
		
		this._label.text = this._exposedValue.name;
		updateEditable();
	}
	
	override public function updateExposedValue(exceptControl:IValueUI = null):Void 
	{
		super.updateExposedValue(exceptControl);
		
		if (this._initialized && this._exposedValue != null)
		{
			var controlsEnabled:Bool = this._controlsEnabled;
			if (this._controlsEnabled) controlsDisable();
			var value:Dynamic = this._exposedValue.value;
			if (value != null)
			{
				assetUpdate(ValEdit.assetLib.getSoundFromSound(cast value));
			}
			else
			{
				assetUpdate(null);
			}
			if (controlsEnabled) controlsEnable();
		}
	}
	
	private function updateEditable():Void
	{
		this.enabled = this._exposedValue.isEditable;
		this._label.enabled = this._exposedValue.isEditable;
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
		this._playButton.removeEventListener(TriggerEvent.TRIGGER, onPlayButton);
		this._stopButton.removeEventListener(TriggerEvent.TRIGGER, onStopButton);
	}
	
	override function controlsEnable():Void 
	{
		if (this._readOnly) return;
		if (this._controlsEnabled) return;
		super.controlsEnable();
		this._loadButton.addEventListener(TriggerEvent.TRIGGER, onLoadButton);
		this._clearButton.addEventListener(TriggerEvent.TRIGGER, onClearButton);
		this._playButton.addEventListener(TriggerEvent.TRIGGER, onPlayButton);
		this._stopButton.addEventListener(TriggerEvent.TRIGGER, onStopButton);
	}
	
	private function onClearButton(evt:TriggerEvent):Void
	{
		if (this._exposedValue.useActions)
		{
			if (this._exposedValue.value != null)
			{
				var action:MultiAction = MultiAction.fromPool();
				
				var valueChange:ValueChange = ValueChange.fromPool();
				var previousValue:Dynamic = ValEdit.assetLib.getSoundFromSound(cast this._exposedValue.value);
				valueChange.setup(this._exposedValue, null, previousValue);
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
		FeathersWindows.showSoundAssets(assetSelected, null, "Select sound asset");
	}
	
	private function assetSelected(asset:SoundAsset):Void
	{
		if (this._exposedValue.useActions)
		{
			var action:MultiAction = MultiAction.fromPool();
			
			var valueChange:ValueChange = ValueChange.fromPool();
			var previousValue:Dynamic = ValEdit.assetLib.getSoundFromSound(cast this._exposedValue.value);
			valueChange.setup(this._exposedValue, asset, previousValue);
			action.add(valueChange);
			
			var valueUIUpdate:ValueUIUpdate = ValueUIUpdate.fromPool();
			valueUIUpdate.setup(this._exposedValue);
			action.addPost(valueUIUpdate);
			
			ValEditor.actionStack.add(action);
		}
		else
		{
			this._exposedValue.value = asset;
			assetUpdate(asset);
		}
	}
	
	private function assetUpdate(asset:SoundAsset):Void
	{
		if (asset == null)
		{
			this._nameLabel.text = "";
			this._pathLabel.text = "";
			this._durationLabel.text = "";
		}
		else
		{
			this._nameLabel.text = asset.name;
			this._pathLabel.text = asset.path;
			this._durationLabel.text = TimeUtil.msToString(asset.content.length);
		}
	}
	
	private function onPlayButton(evt:TriggerEvent):Void
	{
		if (this._soundChannel != null) 
		{
			this._soundChannel.stop();
			this._soundChannel = null;
		}
		
		var value:Dynamic = this._exposedValue.value;
		if (value != null)
		{
			if (Std.isOfType(value, Sound))
			{
				this._soundChannel = cast(value, Sound).play();
			}
			else
			{
				this._soundChannel = cast(value, SoundAsset).content.play();
			}
		}
	}
	
	private function onStopButton(evt:TriggerEvent):Void
	{
		if (this._soundChannel != null)
		{
			this._soundChannel.stop();
			this._soundChannel = null;
		}
	}
	
}