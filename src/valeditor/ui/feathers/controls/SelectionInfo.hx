package valeditor.ui.feathers.controls;

import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import openfl.errors.Error;
import valeditor.ValEditorFrameGroup;
import valeditor.ValEditorTemplateGroup;
import valeditor.events.SelectionEvent;
import valeditor.ui.feathers.Padding;
import valeditor.ui.feathers.Spacing;
import valeditor.ui.feathers.theme.variant.LabelVariant;

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
	
	private var _idGroup:LayoutGroup;
	private var _idLabel:Label;
	private var _idValue:Label;
	
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
		this._idGroup = new LayoutGroup();
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.TOP;
		hLayout.gap = Spacing.HORIZONTAL_GAP;
		this._idGroup.layout = hLayout;
		addChild(this._idGroup);
		
		this._idLabel = new Label("ID");
		this._idLabel.variant = LabelVariant.VALUE_NAME;
		this._idGroup.addChild(this._idLabel);
		
		this._idValue = new Label();
		this._idValue.layoutData = new HorizontalLayoutData(100);
		this._idGroup.addChild(this._idValue);
		
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
		
		ValEditor.selection.addEventListener(SelectionEvent.CHANGE, onObjectSelectionChange);
		objectUpdate();
	}
	
	private function objectUpdate():Void
	{
		if (this._object == null)
		{
			this._idValue.text = "-";
			this._classValue.text = "-";
			this._typeValue.text = "-";
		}
		else
		{
			var singleClass:Bool = true;
			var className:String = null;
			
			if (Std.isOfType(this._object, ValEditorTemplate))
			{
				var template:ValEditorTemplate = cast this._object;
				this._idValue.text = template.id;
				this._classValue.text = template.clss.className;
				this._typeValue.text = "Template";
			}
			else if (Std.isOfType(this._object, ValEditorTemplateGroup))
			{
				var templateGroup:ValEditorTemplateGroup = cast this._object;
				this._idValue.text = templateGroup.numTemplates + " templates";
				
				for (template in templateGroup)
				{
					if (className == null)
					{
						className = template.clss.className;
					}
					else if (template.clss.className != className)
					{
						singleClass = false;
						break;
					}
				}
				
				if (singleClass)
				{
					this._classValue.text = className;
				}
				else
				{
					this._classValue.text = "(multiple classes)";
				}
				this._typeValue.text = "Template";
			}
			else if (Std.isOfType(this._object, ValEditorObject))
			{
				var obj:ValEditorObject = cast this._object;
				this._idValue.text = obj.id;
				this._classValue.text = obj.className;
				this._typeValue.text = "Object";
			}
			else if (Std.isOfType(this._object, ValEditorObjectGroup))
			{
				var objectGroup:ValEditorObjectGroup = cast this._object;
				this._idValue.text = objectGroup.numObjects + " objects";
				
				for (valObject in objectGroup)
				{
					if (className == null)
					{
						className = valObject.className;
					}
					else if (valObject.className != className)
					{
						singleClass = false;
						break;
					}
				}
				if (singleClass)
				{
					this._classValue.text = className;
				}
				else
				{
					this._classValue.text = "(multiple classes)";
				}
				this._typeValue.text = "Object";
			}
			else if (Std.isOfType(this._object, ValEditorKeyFrame))
			{
				this._idValue.text = "-";
				this._classValue.text = "ValEditKeyFrame";
				this._typeValue.text = "KeyFrame";
			}
			else if (Std.isOfType(this._object, ValEditorFrameGroup))
			{
				var frameGroup:ValEditorFrameGroup = cast this._object;
				this._idValue.text = frameGroup.numFrames + " keyframes";
				this._classValue.text = "ValEditKeyFrame";
				this._typeValue.text = "KeyFrame";
			}
			else
			{
				throw new Error("missing ValEditorObject");
			}
		}
	}
	
	private function onObjectSelectionChange(evt:SelectionEvent):Void
	{
		this.object = evt.object;
	}
	
}