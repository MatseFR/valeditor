package valeditor;

import openfl.events.Event;
import valedit.ValEditKeyFrame;
import valedit.ValEditObject;
import valeditor.events.DefaultEvent;

/**
 * ...
 * @author Matse
 */
class ValEditorKeyFrame extends ValEditKeyFrame 
{
	static private var _POOL:Array<ValEditorKeyFrame> = new Array<ValEditorKeyFrame>();
	
	static public function fromPool():ValEditorKeyFrame
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ValEditorKeyFrame();
	}
	
	override function set_indexCurrent(value:Int):Int 
	{
		if (this._indexCurrent == value) return value;
		this._indexCurrent = value;
		if (this._tween)
		{
			if (this._indexCurrent == this.indexStart)
			{
				for (object in this.objects)
				{
					cast(object, ValEditorObject).isSelectable = true;
				}
			}
			else
			{
				for (object in this.objects)
				{
					cast(object, ValEditorObject).isSelectable = false;
				}
			}
		}
		updateTweens();
		return this._indexCurrent;
	}
	
	override function set_tween(value:Bool):Bool 
	{
		if (this._tween == value) return value;
		super.set_tween(value);
		DefaultEvent.dispatch(this, Event.CHANGE);
		return this._tween;
	}
	
	public function new() 
	{
		super();
	}
	
	override public function clear():Void 
	{
		for (object in this.objects)
		{
			ValEditor.destroyObject(cast object);
		}
		this.objects.resize(0);
		super.clear();
	}
	
	override public function pool():Void 
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function clone(?keyFrame:ValEditKeyFrame):ValEditKeyFrame
	{
		if (keyFrame == null) keyFrame = fromPool();
		
		
		
		return keyFrame;
	}
	
	public function copyObjectsFrom(keyFrame:ValEditKeyFrame):Void
	{
		for (object in keyFrame.objects)
		{
			add(ValEditor.cloneObject(object));
		}
	}
	
	override public function add(object:ValEditObject):Void 
	{
		super.add(object);
		if (this._tween)
		{
			resetTweens();
		}
		var prevFrame:ValEditKeyFrame = this.timeLine.getPreviousKeyFrame(this);
		if (prevFrame != null && prevFrame._tween)
		{
			prevFrame.resetTweens();
		}
		if (this.objects.length == 1) DefaultEvent.dispatch(this, Event.CHANGE);
	}
	
	override public function remove(object:ValEditObject):Void 
	{
		super.remove(object);
		if (this._tween) resetTweens();
		var prevFrame:ValEditKeyFrame = this.timeLine.getPreviousKeyFrame(this);
		if (prevFrame != null && prevFrame._tween)
		{
			prevFrame.resetTweens();
		}
		if (this.objects.length == 0) DefaultEvent.dispatch(this, Event.CHANGE);
	}
	
	override function buildTweens():Void 
	{
		for (object in this.objects)
		{
			object.collection.applyToObject(object.object);
		}
		super.buildTweens();
	}
	
}