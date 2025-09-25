package valeditor.ui.feathers.controls;

import feathers.controls.TextInput;
import feathers.core.IValidating;
import openfl.events.Event;

/**
 * Extends TextInput and does not force paddingTop on leftView and rightView so that they remain centered vertically
 * @author Matse
 */
class TextInputIcon extends TextInput 
{

	public function new(text:String="", ?prompt:String, ?changeListener:(Event)->Void) 
	{
		super(text, prompt, changeListener);
		
	}
	
	override function layoutContent():Void {
		var oldIgnoreLeftViewResize = this._ignoreLeftViewResize;
		this._ignoreLeftViewResize = true;
		var oldIgnoreRightViewResize = this._ignoreRightViewResize;
		this._ignoreRightViewResize = true;

		this.layoutBackgroundSkin();

		var textFieldHeight = this._textMeasuredHeight;
		var maxHeight = this.actualHeight - this.paddingTop - this.paddingBottom;
		if (maxHeight < 0.0) {
			maxHeight = 0.0;
		}
		if (textFieldHeight > maxHeight || this.verticalAlign == JUSTIFY) {
			textFieldHeight = maxHeight;
		}
		if (textFieldHeight < 0.0) {
			textFieldHeight = 0.0;
		}
		this.textField.height = textFieldHeight;

		var leftViewOffset = 0.0;
		if (this._currentLeftView != null) {
			if ((this._currentLeftView is IValidating)) {
				(cast this._currentLeftView : IValidating).validateNow();
			}
			this._currentLeftView.x = this.paddingLeft;
			//this._currentLeftView.y = Math.max(this.paddingTop, this.paddingTop + (maxHeight - this._currentLeftView.height) / 2.0);
			this._currentLeftView.y = this.paddingTop + (maxHeight - this._currentLeftView.height) / 2.0;
			leftViewOffset = this._currentLeftView.width + this.leftViewGap;
		}
		var rightViewOffset = 0.0;
		if (this._currentRightView != null) {
			if ((this._currentRightView is IValidating)) {
				(cast this._currentRightView : IValidating).validateNow();
			}
			this._currentRightView.x = this.actualWidth - this.paddingRight - this._currentRightView.width;
			//this._currentRightView.y = Math.max(this.paddingTop, this.paddingTop + (maxHeight - this._currentRightView.height) / 2.0);
			this._currentRightView.y = this.paddingTop + (maxHeight - this._currentRightView.height) / 2.0;
			rightViewOffset = this._currentRightView.width + this.rightViewGap;
		}

		var textFieldWidth = this.actualWidth - this.paddingLeft - this.paddingRight - leftViewOffset - rightViewOffset;
		if (textFieldWidth < 0.0) {
			// flash may sometimes render a TextField with negative width
			// so make sure it is never smaller than 0.0
			textFieldWidth = 0.0;
		}
		this.textField.width = textFieldWidth;

		this.textField.x = this.paddingLeft + leftViewOffset;
		this.alignTextField(this.textField, textFieldHeight, maxHeight);

		if (this.promptTextField != null) {
			this.promptTextField.width = textFieldWidth;

			var textFieldHeight = this._promptTextMeasuredHeight;
			if (textFieldHeight > maxHeight || this.verticalAlign == JUSTIFY) {
				textFieldHeight = maxHeight;
			}
			if (textFieldHeight < 0.0) {
				textFieldHeight = 0.0;
			}
			this.promptTextField.height = textFieldHeight;

			this.promptTextField.x = this.paddingLeft + leftViewOffset;
			this.alignTextField(this.promptTextField, textFieldHeight, maxHeight);
		}
		this._ignoreLeftViewResize = oldIgnoreLeftViewResize;
		this._ignoreRightViewResize = oldIgnoreRightViewResize;
	}
	
}