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
	
	public var isPlaying(get, set):Bool;
	
	override function set_indexCurrent(value:Int):Int 
	{
		if (this._indexCurrent == value) return value;
		this._indexCurrent = value;
		updateObjectsSelectable();
		updateTweens();
		return this._indexCurrent;
	}
	
	private var _isPlaying:Bool;
	private function get_isPlaying():Bool { return this._isPlaying; }
	private function set_isPlaying(value:Bool):Bool
	{
		if (this._isPlaying == value) return value;
		
		this._isPlaying = value;
		if (this._isPlaying)
		{
			for (object in this.objects)
			{
				cast(object, ValEditorObject).isSelectable = false;
			}
		}
		else
		{
			updateObjectsSelectable();
		}
		return this._isPlaying;
	}
	
	override function set_tween(value:Bool):Bool 
	{
		if (this._tween == value) return value;
		super.set_tween(value);
		updateObjectsSelectable();
		updateTweens();
		DefaultEvent.dispatch(this, Event.CHANGE); // this is used by the timeline UI item to update frames state
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
			rebuildTweens();
		}
		var prevFrame:ValEditKeyFrame = this.timeLine.getPreviousKeyFrame(this);
		if (prevFrame != null && prevFrame._tween)
		{
			prevFrame.rebuildTweens();
		}
		if (this.objects.length == 1) DefaultEvent.dispatch(this, Event.CHANGE);
	}
	
	override public function remove(object:ValEditObject):Void 
	{
		super.remove(object);
		if (this._tween) rebuildTweens();
		var prevFrame:ValEditKeyFrame = this.timeLine.getPreviousKeyFrame(this);
		if (prevFrame != null && prevFrame._tween)
		{
			prevFrame.rebuildTweens();
		}
		if (this.objects.length == 0) DefaultEvent.dispatch(this, Event.CHANGE);
	}
	
	override public function exit():Void 
	{
		super.exit();
		
		// unselect objects if needed
		for (object in this.objects)
		{
			if (ValEditor.selection.hasObject(cast object))
			{
				ValEditor.selection.removeObject(cast object);
			}
		}
	}
	
	public function selectAllObjects():Void
	{
		for (object in this.objects)
		{
			if (!ValEditor.selection.hasObject(cast object))
			{
				ValEditor.selection.addObject(cast object);
			}
		}
	}
	
	private function updateObjectsSelectable():Void
	{
		if (this._isPlaying) return;
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
					if (ValEditor.selection.hasObject(cast object))
					{
						ValEditor.selection.removeObject(cast object);
					}
					cast(object, ValEditorObject).isSelectable = false;
				}
			}
		}
		else
		{
			for (object in this.objects)
			{
				cast(object, ValEditorObject).isSelectable = true;
			}
		}
	}
	
}