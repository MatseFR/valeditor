package ui.feathers.controls;

import events.SelectionEvent;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import ui.feathers.Padding;
import ui.feathers.Spacing;
import ui.feathers.variant.LabelVariant;
import valedit.ValEdit;
import valedit.ValEditObject;
import valedit.ValEditTemplate;

/**
 * ...
 * @author Matse
 */
class SelectionInfo extends LayoutGroup 
{
	public var object(get, set):Dynamic;
	private var _object:Dynamic;
	private function get_object():Dynamic { return this._object; }
	private function set_object(value:Dynamic):Dynamic
	{
		if (this._object == value) return value;
		this._object = value;
		if (this._initialized)
		{
			objectUpdate();
		}
		return value;
	}
	
	private var _nameGroup:LayoutGroup;
	private var _nameLabel:Label;
	private var _nameValue:Label;
	
	private var _classGroup:LayoutGroup;
	private var _classLabel:Label;
	private var _classValue:Label;
	
	private var _typeGroup:LayoutGroup;
	private var _typeLabel:Label;
	private var _typeValue:Label;
	
	public function new() 
	{
		super();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var hLayout:HorizontalLayout;
		var vLayout:VerticalLayout;
		
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.paddingBottom = vLayout.paddingTop = vLayout.paddingRight = Padding.DEFAULT;
		this.layout = vLayout;
		
		// name
		this._nameGroup = new LayoutGroup();
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.TOP;
		hLayout.gap = Spacing.HORIZONTAL_GAP;
		this._nameGroup.layout = hLayout;
		addChild(this._nameGroup);
		
		this._nameLabel = new Label("name");
		this._nameLabel.variant = LabelVariant.VALUE_NAME;
		this._nameGroup.addChild(this._nameLabel);
		
		this._nameValue = new Label();
		this._nameValue.layoutData = new HorizontalLayoutData(100);
		this._nameGroup.addChild(this._nameValue);
		
		// class
		this._classGroup = new LayoutGroup();
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.TOP;
		hLayout.gap = Spacing.HORIZONTAL_GAP;
		this._classGroup.layout = hLayout;
		addChild(this._classGroup);
		
		this._classLabel = new Label("class");
		this._classLabel.variant = LabelVariant.VALUE_NAME;
		this._classGroup.addChild(this._classLabel);
		
		this._classValue = new Label();
		this._classValue.layoutData = new HorizontalLayoutData(100);
		this._classGroup.addChild(this._classValue);
		
		// type
		this._typeGroup = new LayoutGroup();
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.TOP;
		hLayout.gap = Spacing.HORIZONTAL_GAP;
		this._typeGroup.layout = hLayout;
		addChild(this._typeGroup);
		
		this._typeLabel = new Label("type");
		this._typeLabel.variant = LabelVariant.VALUE_NAME;
		this._typeGroup.addChild(this._typeLabel);
		
		this._typeValue = new Label();
		this._typeValue.layoutData = new HorizontalLayoutData(100);
		this._typeGroup.addChild(this._typeValue);
		
		ValEdit.selection.addEventListener(SelectionEvent.CHANGE, onObjectSelectionChange);
		objectUpdate();
	}
	
	private function objectUpdate():Void
	{
		if (this._object == null)
		{
			this._nameValue.text = "-";
			this._classValue.text = "-";
			this._typeValue.text = "-";
		}
		else
		{
			if (Std.isOfType(this._object, ValEditTemplate))
			{
				var template:ValEditTemplate = cast this._object;
				this._nameValue.text = template.name;
				this._classValue.text = template.className;
				this._typeValue.text = "Template";
			}
			else if (Std.isOfType(this._object, ValEditObject))
			{
				var obj:ValEditObject = cast this._object;
				this._nameValue.text = obj.name;
				this._classValue.text = obj.className;
				this._typeValue.text = "Object";
			}
			else
			{
				this._nameValue.text = ValEdit.getObjectName(this._object);
				this._classValue.text = ValEdit.getObjectClassName(this._object);
				this._typeValue.text = "Object";
			}
		}
	}
	
	private function onObjectSelectionChange(evt:SelectionEvent):Void
	{
		this.object = evt.object;
	}
	
}