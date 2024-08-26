package valeditor.editor.action.timeline;

import openfl.errors.Error;
import valeditor.ValEditorKeyFrame;
import valeditor.ValEditorTimeLine;
import valeditor.editor.Selection;
import valeditor.editor.action.MultiAction;
import valeditor.editor.action.object.ObjectUnselect;

/**
 * ...
 * @author Matse
 */
class TimeLineSetFrameIndex extends MultiAction 
{
	static private var _POOL:Array<TimeLineSetFrameIndex> = new Array<TimeLineSetFrameIndex>();
	
	static public function fromPool():TimeLineSetFrameIndex
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TimeLineSetFrameIndex();
	}
	
	public var timeLine:ValEditorTimeLine;
	public var frameIndex:Int;
	public var previousFrameIndex:Int;
	
	override function get_numActions():Int { return super.get_numActions() + 1; }
	
	public function new() 
	{
		super();
		this.autoApply = false;
	}
	
	override public function clear():Void 
	{
		this.timeLine = null;
		
		super.clear();
		
		this.autoApply = false;
	}
	
	override public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(timeLine:ValEditorTimeLine, frameIndex:Int, ?previousFrameIndex:Int, ?selection:Selection):Void
	{
		this.timeLine = timeLine;
		this.frameIndex = frameIndex;
		if (previousFrameIndex != null)
		{
			this.previousFrameIndex = previousFrameIndex;
		}
		else
		{
			this.previousFrameIndex = this.timeLine.frameIndex;
		}
		
		if (selection == null)
		{
			selection = ValEditor.selection;
		}
		
		getActionsForTimeLine(this.timeLine, selection);
		for (line in this.timeLine.slaves)
		{
			getActionsForTimeLine(line, selection);
		}
	}
	
	private function getActionsForTimeLine(timeLine:ValEditorTimeLine, selection:Selection):Void
	{
		var prevKeyFrame:ValEditorKeyFrame;
		var newKeyFrame:ValEditorKeyFrame;
		var objectUnselect:ObjectUnselect;
		
		prevKeyFrame = timeLine.getKeyFrameAt(this.previousFrameIndex);
		newKeyFrame = timeLine.getKeyFrameAt(this.frameIndex);
		
		if (newKeyFrame != prevKeyFrame && prevKeyFrame != null)
		{
			objectUnselect = ObjectUnselect.fromPool();
			objectUnselect.setup();
			
			for (object in prevKeyFrame.objects)
			{
				if (selection.hasObject(object))
				{
					objectUnselect.addObject(object);
				}
			}
			
			if (objectUnselect.numObjects == 0)
			{
				objectUnselect.pool();
			}
			else
			{
				add(objectUnselect);
			}
		}
	}
	
	override public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("TimeLineFrameIndex already applied");
		}
		
		this.timeLine.frameIndex = this.frameIndex;
		
		super.apply();
	}
	
	override public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("TimeLineFrameIndex already cancelled");
		}
		
		this.timeLine.frameIndex = this.previousFrameIndex;
		
		super.cancel();
	}
	
}