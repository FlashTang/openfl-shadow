package;

import openfl.display.Sprite;

class Box extends Sprite {
    public function new(width:Float,height:Float) {
        super();
        this.graphics.beginFill(0xffff00,0.8);
        this.graphics.lineStyle(2,0xff0000);
        this.graphics.drawRect(0,0,width,height);
        this.graphics.endFill();
    }
}