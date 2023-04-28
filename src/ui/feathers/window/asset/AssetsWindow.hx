package ui.feathers.window.asset;

import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.controls.Panel;
import feathers.core.PopUpManager;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.TiledRowsListLayout;
import feathers.layout.VerticalAlign;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.net.FileFilter;
#if desktop
import utils.file.FilesOpenerDesktop;
import utils.file.FolderOpener;
import openfl.filesystem.File;
#else
import utils.file.FilesOpener;
import openfl.net.FileReference;
#end

/**
 * ...
 * @author Matse
 */
class AssetsWindow<T> extends Panel 
{
	public var cancelCallback(get, set):Void->Void;
	private var _cancelCallback:Void->Void;
	private function get_cancelCallback():Void->Void { return this._cancelCallback; }
	private function set_cancelCallback(value:Void->Void):Void->Void
	{
		return this._cancelCallback = value;
	}
	
	public var cancelEnabled(get, set):Bool;
	private var _cancelEnabled:Bool = true;
	private function get_cancelEnabled():Bool { return this._cancelEnabled; }
	private function set_cancelEnabled(value:Bool):Bool
	{
		return this._cancelEnabled = value;
	}
	
	public var closeOnSelection(get, set):Bool;
	private var _closeOnSelection:Bool = false;
	private function get_closeOnSelection():Bool { return this._closeOnSelection; }
	private function set_closeOnSelection(value:Bool):Bool
	{
		return this._closeOnSelection = value;
	}
	
	public var filesEnabled(get, set):Bool;
	private var _filesEnabled:Bool = true;
	private function get_filesEnabled():Bool { return this._filesEnabled; }
	private function set_filesEnabled(value:Bool):Bool
	{
		return this._filesEnabled = value;
	}
	
	public var headerEnabled(get, set):Bool;
	private var _headerEnabled:Bool = true;
	private function get_headerEnabled():Bool { return this._headerEnabled; }
	private function set_headerEnabled(value:Bool):Bool
	{
		return this._headerEnabled = value;
	}
	
	public var removeEnabled(get, set):Bool;
	private var _removeEnabled:Bool = false;
	private function get_removeEnabled():Bool { return this._removeEnabled; }
	private function set_removeEnabled(value:Bool):Bool
	{
		return this._removeEnabled = value;
	}
	
	public var selectionCallback(get, set):T->Void;
	private var _selectionCallback:T->Void;
	private function get_selectionCallback():T->Void { return this._selectionCallback; }
	private function set_selectionCallback(value:T->Void):T->Void
	{
		return this._selectionCallback = value;
	}
	
	public var title(get, set):String;
	private var _title:String = "";
	private function get_title():String { return this._title; }
	private function set_title(value:String):String
	{
		if (value == null) value = "";
		if (_titleLabel != null)
		{
			_titleLabel.text = value;
		}
		return this._title = value;
	}
	
	private var _headerGroup:LayoutGroup;
	private var _titleLabel:Label;
	
	private var _footerGroup:LayoutGroup;
	private var _assetList:ListView;
	
	private var _addFilesButton:Button;
	#if desktop
	private var _addFolderButton:Button;
	#end
	private var _cancelButton:Button;
	private var _removeButton:Button;
	
	private var _buttonList:Array<Button> = new Array<Button>();
	
	private var _extensionList:Array<String>;
	private var _filterList:Array<FileFilter>;
	
	#if desktop
	private var _fileOpener:FilesOpenerDesktop = new FilesOpenerDesktop();
	private var _fileDialogTitle:String = "Select file(s)";
	private var _folderOpener:FolderOpener = new FolderOpener();
	private var _folderDialogTitle:String = "Select folder";
	#else
	private var _fileOpener:FilesOpener = new FilesOpener();
	#end
	
	private var _controlsEnabled:Bool;
	
	public function new() 
	{
		super();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var hLayout:HorizontalLayout;
		var listLayout:TiledRowsListLayout;
		
		this.layout = new AnchorLayout();
		
		if (_headerEnabled)
		{
			_headerGroup = new LayoutGroup();
			_headerGroup.variant = LayoutGroup.VARIANT_TOOL_BAR;
			hLayout = new HorizontalLayout();
			hLayout.horizontalAlign = HorizontalAlign.CENTER;
			hLayout.verticalAlign = VerticalAlign.MIDDLE;
			hLayout.setPadding(Padding.DEFAULT);
			_headerGroup.layout = hLayout;
			this.header = _headerGroup;
			
			_titleLabel = new Label(this._title);
			_headerGroup.addChild(_titleLabel);
		}
		
		_footerGroup = new LayoutGroup();
		_footerGroup.variant = LayoutGroup.VARIANT_TOOL_BAR;
		//_footerGroup.layoutData = new AnchorLayoutData(null, 0, 0, 0);
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.CENTER;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.setPadding(Padding.DEFAULT);
		_footerGroup.layout = hLayout;
		this.footer = _footerGroup;
		
		_addFilesButton = new Button("add file(s)");
		if (_filesEnabled)
		{
			_footerGroup.addChild(_addFilesButton);
		}
		_buttonList.push(_addFilesButton);
		
		#if desktop
		_addFolderButton = new Button("add folder");
		if (_filesEnabled)
		{
			_footerGroup.addChild(_addFolderButton);
		}
		_buttonList.push(_addFolderButton);
		#end
		
		_cancelButton = new Button("cancel");
		if (_cancelEnabled)
		{
			_footerGroup.addChild(_cancelButton);
		}
		_buttonList.push(_cancelButton);
		
		if (_removeEnabled)
		{
			_removeButton = new Button("remove selected");
			_removeButton.enabled = false;
			_footerGroup.addChild(_removeButton);
			//_buttonList.push(_removeButton);
		}
		
		_assetList = new ListView();
		_assetList.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		listLayout = new TiledRowsListLayout();
		listLayout.setPadding(Padding.DEFAULT);
		listLayout.setGap(Spacing.DEFAULT);
		_assetList.layout = listLayout;
		_assetList.allowMultipleSelection = _removeEnabled;
		addChild(_assetList);
		
		//controlsEnable();
	}
	
	public function reset():Void
	{
		if (_assetList != null) 
		{
			var controlsEnabled:Bool = _controlsEnabled;
			if (controlsEnabled) controlsDisable();
			_assetList.selectedIndex = -1;
			if (controlsEnabled) controlsEnable();
		}
	}
	
	private function controlsDisable():Void
	{
		if (!_controlsEnabled) return;
		_assetList.removeEventListener(Event.CHANGE, onSelectionChange);
		_addFilesButton.removeEventListener(TriggerEvent.TRIGGER, onAddFilesButton);
		#if desktop
		_addFolderButton.removeEventListener(TriggerEvent.TRIGGER, onAddFolderButton);
		#end
		if (_cancelButton != null) _cancelButton.removeEventListener(TriggerEvent.TRIGGER, onCancelButton);
		if (_removeButton != null) _removeButton.removeEventListener(TriggerEvent.TRIGGER, onRemoveButton);
		_controlsEnabled = false;
	}
	
	private function controlsEnable():Void
	{
		if (_controlsEnabled) return;
		_assetList.addEventListener(Event.CHANGE, onSelectionChange);
		_addFilesButton.addEventListener(TriggerEvent.TRIGGER, onAddFilesButton);
		#if desktop
		_addFolderButton.addEventListener(TriggerEvent.TRIGGER, onAddFolderButton);
		#end
		if (_cancelButton != null) _cancelButton.addEventListener(TriggerEvent.TRIGGER, onCancelButton);
		if (_removeButton != null) _removeButton.addEventListener(TriggerEvent.TRIGGER, onRemoveButton);
		_controlsEnabled = true;
	}
	
	private function disableUI():Void
	{
		_assetList.selectable = false;
		for (btn in _buttonList)
		{
			btn.enabled = false;
		}
		if (_removeButton != null) _removeButton.enabled = false;
	}
	
	private function enableUI():Void
	{
		_assetList.selectable = true;
		for (btn in _buttonList)
		{
			btn.enabled = true;
		}
		if (_removeButton != null) _removeButton.enabled = _assetList.selectedIndices.length != 0;
	}
	
	private function onSelectionChange(evt:Event):Void
	{
		if (this._selectionCallback != null)
		{
			this._selectionCallback(_assetList.selectedItem);
		}
		if (this._closeOnSelection)
		{
			PopUpManager.removePopUp(this);
		}
		if (_removeButton != null)
		{
			_removeButton.enabled = _assetList.selectedIndices.length != 0;
		}
	}
	
	#if desktop
	private function onAddFilesButton(evt:TriggerEvent):Void
	{
		disableUI();
		_fileOpener.start(onAddFilesComplete, onAddFilesCancel, _filterList, _fileDialogTitle);
	}
	
	private function onAddFilesCancel():Void
	{
		enableUI();
	}
	
	private function onAddFilesComplete(files:Array<File>):Void
	{
		throw new Error("override onAddFilesComplete function");
	}
	
	private function onAddFolderButton(evt:TriggerEvent):Void
	{
		disableUI();
		_folderOpener.start(onAddFolderComplete, onAddFolderCancel, _extensionList, _folderDialogTitle);
	}
	
	private function onAddFolderCancel():Void
	{
		enableUI();
	}
	
	private function onAddFolderComplete(files:Array<File>):Void
	{
		throw new Error("override onAddFolderComplete function");
	}
	#else
	private function onAddFilesButton(evt:TriggerEvent):Void
	{
		disableUI();
		_fileOpener.start(onAddFilesComplete, onAddFilesCancel, _filterList);
	}
	
	private function onAddFilesCancel():Void
	{
		enableUI();
	}
	
	private function onAddFilesComplete(files:Array<FileReference>):Void
	{
		throw new Error("override onAddFilesComplete function");
	}
	#end
	
	private function onCancelButton(evt:TriggerEvent):Void
	{
		PopUpManager.removePopUp(this);
		if (_cancelCallback != null) _cancelCallback();
	}
	
	private function onRemoveButton(evt:TriggerEvent):Void
	{
		
	}
	
}