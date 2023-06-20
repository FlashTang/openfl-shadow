package;

import openfl.events.Event;
import openfl.geom.Point;
import openfl.events.MouseEvent;
import openfl.display.Sprite;

class Main extends Sprite {

	var padding:Float = 6;
	var boxes:Array<Box> = []; // 障碍物数组
	var hero:Sprite;
	var corners:Array<Array<Point>> = [];

	var borderLines:Array<Array<Point>>;

	public function new() {
		super();
		stage.frameRate = 60;

		resizeHandler(null);

		var posses:Array<Point> = [new Point(100, 300), new Point(300, 100), new Point(500, 130)];
		for (pos in posses) {
			var box = new Box(Math.random() * 30 + 70, Math.random() * 30 + 70);
			box.x = pos.x;
			box.y = pos.y;
			addChild(box);
			boxes.push(box);
		}

		for (box in boxes) {
			corners.push([
				new Point(box.x, box.y), // 左上角
				new Point(box.x + box.width, box.y), // 右上角
				new Point(box.x, box.y + box.height), // 左下角
				new Point(box.x + box.width, box.y + box.height) // 右下角
			]);
			//break;
		}

		hero = new Sprite();
		hero.graphics.beginFill(0x0000ff, 0.8);
		hero.graphics.lineStyle(2, 0);
		hero.graphics.drawCircle(0, 0, 20);
		hero.graphics.endFill();
		addChild(hero);

		stage.addEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
		stage.addEventListener(Event.RESIZE, resizeHandler);
	}


	function resizeHandler(e:Event) {
		borderLines = [
			[new Point(padding, padding), new Point(stage.stageWidth - padding, padding)], // 上
			[new Point(padding, padding), new Point(padding, stage.stageHeight - padding)], // 左
			[
				new Point(padding, stage.stageHeight - padding),
				new Point(stage.stageWidth - padding, stage.stageHeight - padding)
			], // 下
			[
				new Point(stage.stageWidth - padding, padding),
				new Point(stage.stageWidth - padding, stage.stageHeight - padding)
			], // 右
		];
	}

	function moveHandler(e:openfl.events.MouseEvent) {
		hero.x += (stage.mouseX - hero.x) * 0.8;
		hero.y += (stage.mouseY - hero.y) * 0.8;
		drawShadow();
	}

	function drawShadow() {
		this.graphics.clear();
		for (corner4 in corners) {
			var intersectedBorderIndexs:Array<Int> = [];
			var intersectedPointsInBorders:Array<Array<IntersectPointsAndCornerPoints>> = [[],[],[],[]];
			
			for (idx => point in corner4) {
				this.graphics.moveTo(hero.x,hero.y);
				this.graphics.lineStyle(1,0x00ff00);
				var c:Point = extendLinePointC(new Point(hero.x,hero.y),new Point(point.x,point.y),100000);
				//这里找出射线和边框的相交位置，一旦找到即break，因为不会发生和多线相交（除非是边角顶点）
				for (index => borderLine in borderLines) {
					if(intersects(hero.x,hero.y,c.x,c.y,borderLine[0].x,borderLine[0].y,borderLine[1].x,borderLine[1].y)){
						var p = line_intersect(hero.x,hero.y,c.x,c.y,borderLine[0].x,borderLine[0].y,borderLine[1].x,borderLine[1].y);
						//this.graphics.lineTo(p.x,p.y);
						intersectedBorderIndexs.push(index);
						intersectedPointsInBorders[index].push({pt: p,cornerIndex: idx,pt_corner: new Point(point.x,point.y)});
						break;
					}
				}
				//this.graphics.lineTo(c.x,c.y);
			}
			
			trace(intersectedPointsInBorders);
			//上左下右，0123
			var state = "";
			for (i => intersectPointsAndCornerPoints in intersectedPointsInBorders) {
				if(intersectPointsAndCornerPoints.length > 0){
					state = state + Std.string(i);
				}
			}
			trace(state.length);
			var drawPoints:Array<Point> = [];
			if(state == "01"){ //上左
				var intersectPointsAndCornerPoints:Array<IntersectPointsAndCornerPoints> = intersectedPointsInBorders[0];
				intersectPointsAndCornerPoints.sort(function s(a:IntersectPointsAndCornerPoints,b:IntersectPointsAndCornerPoints) {
					return Std.int(a.pt.x * 1000000 - b.pt.x * 1000000);
				});
				drawPoints.push(intersectPointsAndCornerPoints[intersectPointsAndCornerPoints.length - 1].pt_corner);
				drawPoints.push(intersectPointsAndCornerPoints[intersectPointsAndCornerPoints.length - 1].pt);
				drawPoints.push(borderLines[0][0]);

				intersectPointsAndCornerPoints = intersectedPointsInBorders[1];
				intersectPointsAndCornerPoints.sort(function s(a:IntersectPointsAndCornerPoints,b:IntersectPointsAndCornerPoints) {
					return Std.int(a.pt.y * 1000000 - b.pt.y * 1000000);
				});
				drawPoints.push(intersectPointsAndCornerPoints[intersectPointsAndCornerPoints.length - 1].pt);
				drawPoints.push(intersectPointsAndCornerPoints[intersectPointsAndCornerPoints.length - 1].pt_corner);
			}
			else if(state == "03"){ //上左
				var intersectPointsAndCornerPoints:Array<IntersectPointsAndCornerPoints> = intersectedPointsInBorders[0];
				intersectPointsAndCornerPoints.sort(function s(a:IntersectPointsAndCornerPoints,b:IntersectPointsAndCornerPoints) {
					return Std.int(a.pt.x * 1000000 - b.pt.x * 1000000);
				});
				drawPoints.push(intersectPointsAndCornerPoints[0].pt_corner);
				drawPoints.push(intersectPointsAndCornerPoints[0].pt);
				drawPoints.push(borderLines[0][1]);

				intersectPointsAndCornerPoints = intersectedPointsInBorders[3];
				intersectPointsAndCornerPoints.sort(function s(a:IntersectPointsAndCornerPoints,b:IntersectPointsAndCornerPoints) {
					return Std.int(a.pt.y * 1000000 - b.pt.y * 1000000);
				});
				drawPoints.push(intersectPointsAndCornerPoints[intersectPointsAndCornerPoints.length - 1].pt);
				drawPoints.push(intersectPointsAndCornerPoints[intersectPointsAndCornerPoints.length - 1].pt_corner);
			}
			else if(state == "23"){ //右下
				var intersectPointsAndCornerPoints:Array<IntersectPointsAndCornerPoints> = intersectedPointsInBorders[3];
				intersectPointsAndCornerPoints.sort(function s(a:IntersectPointsAndCornerPoints,b:IntersectPointsAndCornerPoints) {
					return Std.int(a.pt.y * 1000000 - b.pt.y * 1000000);
				});
				drawPoints.push(intersectPointsAndCornerPoints[0].pt_corner);
				drawPoints.push(intersectPointsAndCornerPoints[0].pt);
				drawPoints.push(borderLines[3][1]);

				intersectPointsAndCornerPoints = intersectedPointsInBorders[2];
				intersectPointsAndCornerPoints.sort(function s(a:IntersectPointsAndCornerPoints,b:IntersectPointsAndCornerPoints) {
					return Std.int(a.pt.x * 1000000 - b.pt.x * 1000000);
				});
				drawPoints.push(intersectPointsAndCornerPoints[0].pt);
				drawPoints.push(intersectPointsAndCornerPoints[0].pt_corner);
			}
			else if(state == "023"){ //右下
				var intersectPointsAndCornerPoints:Array<IntersectPointsAndCornerPoints> = intersectedPointsInBorders[0];
				intersectPointsAndCornerPoints.sort(function s(a:IntersectPointsAndCornerPoints,b:IntersectPointsAndCornerPoints) {
					return Std.int(a.pt.x * 1000000 - b.pt.x * 1000000);
				});
				drawPoints.push(intersectPointsAndCornerPoints[0].pt_corner);
				drawPoints.push(intersectPointsAndCornerPoints[0].pt);
				drawPoints.push(borderLines[3][0]);
				drawPoints.push(borderLines[3][1]);

				intersectPointsAndCornerPoints = intersectedPointsInBorders[2];
				intersectPointsAndCornerPoints.sort(function s(a:IntersectPointsAndCornerPoints,b:IntersectPointsAndCornerPoints) {
					return Std.int(a.pt.x * 1000000 - b.pt.x * 1000000);
				});
				drawPoints.push(intersectPointsAndCornerPoints[0].pt);
				drawPoints.push(intersectPointsAndCornerPoints[0].pt_corner);
			}
			else if(state == "013"){ //上左右
				var intersectPointsAndCornerPoints:Array<IntersectPointsAndCornerPoints> = intersectedPointsInBorders[1];
				intersectPointsAndCornerPoints.sort(function s(a:IntersectPointsAndCornerPoints,b:IntersectPointsAndCornerPoints) {
					return Std.int(a.pt.y * 1000000 - b.pt.y * 1000000);
				});
				drawPoints.push(intersectPointsAndCornerPoints[intersectPointsAndCornerPoints.length - 1].pt_corner);
				drawPoints.push(intersectPointsAndCornerPoints[intersectPointsAndCornerPoints.length - 1].pt);
				drawPoints.push(borderLines[0][0]);
				drawPoints.push(borderLines[0][1]);

				intersectPointsAndCornerPoints = intersectedPointsInBorders[3];
				intersectPointsAndCornerPoints.sort(function s(a:IntersectPointsAndCornerPoints,b:IntersectPointsAndCornerPoints) {
					return Std.int(a.pt.y * 1000000 - b.pt.y * 1000000);
				});
				drawPoints.push(intersectPointsAndCornerPoints[intersectPointsAndCornerPoints.length - 1].pt);
				drawPoints.push(intersectPointsAndCornerPoints[intersectPointsAndCornerPoints.length - 1].pt_corner);
			}
			else if(state == "123"){ //左下右边
				var intersectPointsAndCornerPoints:Array<IntersectPointsAndCornerPoints> = intersectedPointsInBorders[1];
				intersectPointsAndCornerPoints.sort(function s(a:IntersectPointsAndCornerPoints,b:IntersectPointsAndCornerPoints) {
					return Std.int(a.pt.y * 1000000 - b.pt.y * 1000000);
				});
				drawPoints.push(intersectPointsAndCornerPoints[0].pt_corner);
				drawPoints.push(intersectPointsAndCornerPoints[0].pt);
				drawPoints.push(borderLines[1][1]);
				drawPoints.push(borderLines[2][1]);

				intersectPointsAndCornerPoints = intersectedPointsInBorders[3];
				intersectPointsAndCornerPoints.sort(function s(a:IntersectPointsAndCornerPoints,b:IntersectPointsAndCornerPoints) {
					return Std.int(a.pt.y * 1000000 - b.pt.y * 1000000);
				});
				drawPoints.push(intersectPointsAndCornerPoints[0].pt);
				drawPoints.push(intersectPointsAndCornerPoints[0].pt_corner);
			}
			else if(state == "012"){ //上左下
				var intersectPointsAndCornerPoints:Array<IntersectPointsAndCornerPoints> = intersectedPointsInBorders[0];
				intersectPointsAndCornerPoints.sort(function s(a:IntersectPointsAndCornerPoints,b:IntersectPointsAndCornerPoints) {
					return Std.int(a.pt.x * 1000000 - b.pt.x * 1000000);
				});
				drawPoints.push(intersectPointsAndCornerPoints[intersectPointsAndCornerPoints.length - 1].pt_corner);
				drawPoints.push(intersectPointsAndCornerPoints[intersectPointsAndCornerPoints.length - 1].pt);
				drawPoints.push(borderLines[0][0]);
				drawPoints.push(borderLines[1][1]);

				intersectPointsAndCornerPoints = intersectedPointsInBorders[2];
				intersectPointsAndCornerPoints.sort(function s(a:IntersectPointsAndCornerPoints,b:IntersectPointsAndCornerPoints) {
					return Std.int(a.pt.x * 1000000 - b.pt.x * 1000000);
				});
				drawPoints.push(intersectPointsAndCornerPoints[intersectPointsAndCornerPoints.length - 1].pt);
				drawPoints.push(intersectPointsAndCornerPoints[intersectPointsAndCornerPoints.length - 1].pt_corner);
			}
			else if(state == "12"){ //左下
				var intersectPointsAndCornerPoints:Array<IntersectPointsAndCornerPoints> = intersectedPointsInBorders[1];
				intersectPointsAndCornerPoints.sort(function s(a:IntersectPointsAndCornerPoints,b:IntersectPointsAndCornerPoints) {
					return Std.int(a.pt.y * 1000000 - b.pt.y * 1000000);
				});
				drawPoints.push(intersectPointsAndCornerPoints[0].pt_corner);
				drawPoints.push(intersectPointsAndCornerPoints[0].pt);
				drawPoints.push(borderLines[1][1]);
				intersectPointsAndCornerPoints = intersectedPointsInBorders[2];
				intersectPointsAndCornerPoints.sort(function s(a:IntersectPointsAndCornerPoints,b:IntersectPointsAndCornerPoints) {
					return Std.int(a.pt.x * 1000000 - b.pt.x * 1000000);
				});
				drawPoints.push(intersectPointsAndCornerPoints[intersectPointsAndCornerPoints.length - 1].pt);
				drawPoints.push(intersectPointsAndCornerPoints[intersectPointsAndCornerPoints.length - 1].pt_corner);
			}
			else if(state.length == 1){
				var intersectPointsAndCornerPoints:Array<IntersectPointsAndCornerPoints> = intersectedPointsInBorders[Std.parseInt(state)];
				intersectPointsAndCornerPoints.sort(function s(a:IntersectPointsAndCornerPoints,b:IntersectPointsAndCornerPoints) {
					if(state == "1" || state == "3"){
						return Std.int(a.pt.y * 1000000 - b.pt.y * 1000000);
					}
					else{
						return Std.int(a.pt.x * 1000000 - b.pt.x * 1000000);
					}
					
				});
				drawPoints.push(intersectPointsAndCornerPoints[0].pt_corner);
				drawPoints.push(intersectPointsAndCornerPoints[0].pt);
				drawPoints.push(intersectPointsAndCornerPoints[intersectPointsAndCornerPoints.length - 1].pt);
				drawPoints.push(intersectPointsAndCornerPoints[intersectPointsAndCornerPoints.length - 1].pt_corner);
			}
			//画出来
			this.graphics.lineStyle(4,0x3700ff);
			this.graphics.beginFill(0x00ff15,0.5);
			
			for (index => drawPoint in drawPoints) {
				if(index == 0){
					this.graphics.moveTo(drawPoint.x,drawPoint.y);
				}
				else{
					this.graphics.lineTo(drawPoint.x,drawPoint.y);
				}
			}
			this.graphics.endFill();

		}
	}
	//参见
	//https://stackoverflow.com/questions/7740507/extend-a-line-segment-a-specific-distance
	function extendLinePointC(a:Point,b:Point,len:Float):Point {
		var lenAB:Float = Math.sqrt(Math.pow(a.x - b.x, 2.0) + Math.pow(a.y - b.y, 2.0));
		return new Point(b.x + (b.x - a.x) / lenAB * len,b.y + (b.y - a.y) / lenAB * len);
	}
	//获取相交点
	function line_intersect(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float, x4:Float, y4:Float):Point {
		var ua:Float,ub:Float,denom:Float = (y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1);
		ua = ((x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3)) / denom;
		ub = ((x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3)) / denom;
		return new Point(x1 + ua * (x2 - x1), y1 + ua * (y2 - y1));
	}

	//判断两条线段是否相交
	function intersects(a:Float, b:Float, c:Float, d:Float, p:Float, q:Float, r:Float, s:Float):Bool {
		var det, gamma, lambda;
		det = (c - a) * (s - q) - (r - p) * (d - b);
		if (det == 0) {
			return false;
		} else {
			lambda = ((s - q) * (r - a) + (p - r) * (s - b)) / det;
			gamma = ((b - d) * (r - a) + (c - a) * (s - b)) / det;
			return (0 < lambda && lambda < 1) && (0 < gamma && gamma < 1);
		}
	};
}


typedef IntersectPointsAndCornerPoints = {
	var pt:Point;
	var ?pt_corner:Point;
	var cornerIndex:Int;
}