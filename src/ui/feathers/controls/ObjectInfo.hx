package ui.feathers.controls;

import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import ui.feathers.Padding;
import ui.feathers.Spacing;
import valedit.ValEdit;

/**
 * ...
 * @author Matse
 */
class ObjectInfo extends LayoutGroup 
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
	
	private var _objectName:Label;
	private var _objectClass:Label;
	
	public function new() 
	{
		super();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var vLayout:VerticalLayout;
		
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.setPadding(Padding.DEFAULT);
		vLayout.gap = Spacing.VERTICAL_GAP;
		this.layout = vLayout;
		
		this._objectName = new Label();
		addChild(this._objectName);
		
		this._objectClass = new Label();
		addChild(this._objectClass);
		
		objectUpdate();
	}
	
	private function objectUpdate():Void
	{
		if (this._object == null)
		{
			this._objectName.text = "";
			this._objectClass.text = "";
		}
		else
		{
			this._objectName.text = ValEdit.getObjectName(this._object);
			this._objectClass.text = ValEdit.getObjectClassName(this._object);
		}
	}
	
}