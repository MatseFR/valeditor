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
	
	public function new() 
	{
		super();
	}
	
	override public function clear():Void 
	{
		super.clear();
	}
	
	override public function pool():Void 
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	override public function add(object:ValEditObject):Void 
	{
		super.add(object);
		if (this.objects.length == 1) DefaultEvent.dispatch(this, Event.CHANGE);
	}
	
	override public function remove(object:ValEditObject):Void 
	{
		super.remove(object);
		if (this.objects.length == 0) DefaultEvent.dispatch(this, Event.CHANGE);
	}
	
}