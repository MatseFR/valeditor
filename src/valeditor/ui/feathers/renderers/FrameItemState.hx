package valeditor.ui.feathers.renderers;

/**
 * @author Matse
 */
enum FrameItemState 
{
	FRAME(selected:Bool);
	FRAME_5(selected:Bool);
	
	KEYFRAME_SINGLE(selected:Bool);
	KEYFRAME_SINGLE_EMPTY(selected:Bool);
	KEYFRAME_SINGLE_TWEEN(selected:Bool);
	KEYFRAME_SINGLE_TWEEN_EMPTY(selected:Bool);
	
	KEYFRAME_START(selected:Bool);
	KEYFRAME_START_EMPTY(selected:Bool);
	KEYFRAME_START_TWEEN(selected:Bool);
	KEYFRAME_START_TWEEN_EMPTY(selected:Bool);
	
	KEYFRAME(selected:Bool);
	KEYFRAME_EMPTY(selected:Bool);
	KEYFRAME_TWEEN(selected:Bool);
	KEYFRAME_TWEEN_EMPTY(selected:Bool);
	
	KEYFRAME_END(selected:Bool);
	KEYFRAME_END_EMPTY(selected:Bool);
	KEYFRAME_END_TWEEN(selected:Bool);
	KEYFRAME_END_TWEEN_EMPTY(selected:Bool);
}