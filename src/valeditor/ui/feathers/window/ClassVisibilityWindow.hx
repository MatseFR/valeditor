package valeditor.ui.feathers.window;

import feathers.controls.Button;
import feathers.controls.GridView;
import feathers.controls.GridViewColumn;
import feathers.controls.Header;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.controls.dataRenderers.SortOrderHeaderRenderer;
import feathers.data.ArrayCollection;
import feathers.data.GridViewCellState;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.utils.DisplayObjectRecycler;
import valeditor.editor.visibility.ClassValueVisibility;
import valeditor.editor.visibility.ClassVisibilityCollection;
import valeditor.ui.feathers.renderers.CheckItemRenderer;
import valeditor.ui.feathers.theme.simple.variants.HeaderVariant;
import valeditor.ui.feathers.theme.variant.ItemRendererVariant;
import valeditor.ui.feathers.theme.variant.SortOrderHeaderRendererVariant;

/**
 * ...
 * @author Matse
 */
class ClassVisibilityWindow extends Panel 
{
	public var cancelCallback(get, set):Void->Void;
	public var confirmCallback(get, set):Void->Void;
	public var title(get, set):String;
	public var visibilityCollection(get, set):ClassVisibilityCollection;
	public var visibilityCollectionDefault(get, set):ClassVisibilityCollection;
	
	private var _cancelCallback:Void->Void;
	private function get_cancelCallback():Void->Void { return this._cancelCallback; }
	private function set_cancelCallback(value:Void->Void):Void->Void
	{
		return this._cancelCallback = value;
	}
	
	private var _confirmCallback:Void->Void;
	private function get_confirmCallback():Void->Void { return this._confirmCallback; }
	private function set_confirmCallback(value:Void->Void):Void->Void
	{
		return this._confirmCallback = value;
	}
	
	private var _title:String;
	private function get_title():String { return this._title; }
	private function set_title(value:String):String
	{
		if (this._title == value) return value;
		if (this._initialized)
		{
			this._headerGroup.text = value;
		}
		return this._title = value;
	}
	
	private var _visibilityCollection:ClassVisibilityCollection;
	private function get_visibilityCollection():ClassVisibilityCollection { return this._visibilityCollection; }
	private function set_visibilityCollection(value:ClassVisibilityCollection):ClassVisibilityCollection
	{
		this._editCollection.clear();
		value.clone(this._editCollection);
		this._gridCollection.updateAll();
		return this._visibilityCollection = value;
	}
	
	private var _visibilityCollectionDefault:ClassVisibilityCollection;
	private function get_visibilityCollectionDefault():ClassVisibilityCollection { return this._visibilityCollectionDefault; }
	private function set_visibilityCollectionDefault(value:ClassVisibilityCollection):ClassVisibilityCollection
	{
		if (this._initialized)
		{
			this._restoreDefaultsButton.enabled = value != null;
		}
		return this._visibilityCollectionDefault = value;
	}
	
	private var _headerGroup:Header;
	private var _footerGroup:LayoutGroup;
	private var _restoreDefaultsButton:Button;
	private var _cancelButton:Button;
	private var _confirmButton:Button;
	
	private var _grid:GridView;
	private var _propertyColumn:GridViewColumn;
	private var _templateColumn:GridViewColumn;
	private var _templateObjectColumn:GridViewColumn;
	private var _objectColumn:GridViewColumn;
	private var _gridCollection:ArrayCollection<ClassValueVisibility>;
	
	private var _editCollection:ClassVisibilityCollection;
	
	public function new() 
	{
		super();
		this._editCollection = ClassVisibilityCollection.fromPool();
		this._gridCollection = new ArrayCollection<ClassValueVisibility>(this._editCollection.valueList);
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var hLayout:HorizontalLayout;
		
		this.layout = new AnchorLayout();
		
		this._headerGroup = new Header(this._title);
		this._headerGroup.variant = HeaderVariant.THEME;
		this.header = this._headerGroup;
		
		this._footerGroup = new LayoutGroup();
		this._footerGroup.variant = LayoutGroup.VARIANT_TOOL_BAR;
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.CENTER;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.setPadding(Padding.DEFAULT);
		this._footerGroup.layout = hLayout;
		this.footer = this._footerGroup;
		
		this._restoreDefaultsButton = new Button("defaults", onRestoreDefaultsButton);
		this._restoreDefaultsButton.enabled = this._visibilityCollectionDefault != null;
		this._footerGroup.addChild(this._restoreDefaultsButton);
		
		this._cancelButton = new Button("cancel", onCancelButton);
		this._footerGroup.addChild(this._cancelButton);
		
		this._confirmButton = new Button("ok", onConfirmButton);
		this._footerGroup.addChild(this._confirmButton);
		
		var recycler = DisplayObjectRecycler.withFunction(() -> {
			var renderer:ItemRenderer = new ItemRenderer();
			renderer.variant = ItemRendererVariant.RIGHT_ALIGNED;
			return renderer;
		});
		recycler.update = (renderer:ItemRenderer, state:GridViewCellState) -> {
			renderer.text = state.data.propertyName;
		};
		this._propertyColumn = new GridViewColumn("property");
		this._propertyColumn.cellRendererRecycler = recycler;
		
		var recycler = DisplayObjectRecycler.withFunction(() -> {
			return CheckItemRenderer.fromPool("templateVisible");
		});
		recycler.update = (renderer:CheckItemRenderer, state:GridViewCellState) -> {
			renderer.object = state.data;
		};
		recycler.destroy = (renderer:CheckItemRenderer) -> {
			renderer.pool();
		};
		this._templateColumn = new GridViewColumn("template", null, 100.0);
		this._templateColumn.cellRendererRecycler = recycler;
		
		recycler = DisplayObjectRecycler.withFunction(() -> {
			return CheckItemRenderer.fromPool("templateObjectVisible");
		});
		recycler.update = (renderer:CheckItemRenderer, state:GridViewCellState) -> {
			renderer.object = state.data;
		};
		recycler.destroy = (renderer:CheckItemRenderer) -> {
			renderer.pool();
		};
		this._templateObjectColumn = new GridViewColumn("template instance", null, 100.0);
		this._templateObjectColumn.cellRendererRecycler = recycler;
		
		recycler = DisplayObjectRecycler.withFunction(() -> {
			return CheckItemRenderer.fromPool("objectVisible");
		});
		recycler.update = (renderer:CheckItemRenderer, state:GridViewCellState) -> {
			renderer.object = state.data;
		};
		recycler.destroy = (renderer:CheckItemRenderer) -> {
			renderer.pool();
		};
		this._objectColumn = new GridViewColumn("class instance", null, 100.0);
		this._objectColumn.cellRendererRecycler = recycler;
		
		var columns:ArrayCollection<GridViewColumn> = new ArrayCollection<GridViewColumn>([
			this._propertyColumn,
			this._templateColumn,
			this._templateObjectColumn,
			this._objectColumn
		]);
		
		var headerRecycler = DisplayObjectRecycler.withFunction(() -> {
			var renderer:SortOrderHeaderRenderer = new SortOrderHeaderRenderer();
			renderer.variant = SortOrderHeaderRendererVariant.CENTER_ALIGNED;
			renderer.wordWrap = true;
			return renderer;
		});
		
		this._grid = new GridView(this._gridCollection, columns);
		this._grid.headerRendererRecycler = headerRecycler;
		this._grid.resizableColumns = true;
		this._grid.allowMultipleSelection = false;
		this._grid.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		addChild(this._grid);
	}
	
	private function onCancelButton(evt:TriggerEvent):Void
	{
		FeathersWindows.closeWindow(this);
		if (this._cancelCallback != null)
		{
			this._cancelCallback();
		}
	}
	
	private function onConfirmButton(evt:TriggerEvent):Void
	{
		this._visibilityCollection.clear();
		this._editCollection.clone(this._visibilityCollection);
		FeathersWindows.closeWindow(this);
		if (this._confirmCallback != null)
		{
			this._confirmCallback();
		}
	}
	
	private function onRestoreDefaultsButton(evt:TriggerEvent):Void
	{
		this._editCollection.clear();
		this._visibilityCollectionDefault.clone(this._editCollection);
		this._gridCollection.updateAll();
	}
	
}