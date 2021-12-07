library float_tab;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class FloatTabView extends StatefulWidget {
  List<String> values;
  int initSelectIndex;
  Color borderColor;
  double borderWidth = 1;
  double borderRadius = 4;
  Color selectLabelColor = Colors.white;
  Color normalLabelColor = Colors.red;
  Color backGroundColor = Colors.white;
  Color slideColor = Colors.red;
  double slideMargin = 4;
  double cellWidth = 60;
  double cellHeight = 40;
  double valueFontSize = 13;

  void Function(int index) onSelectIndex;
  FloatTabView({
    Key key,
    this.values,
    this.initSelectIndex,
    this.onSelectIndex,
    this.borderColor = Colors.red,
    this.borderWidth = 1,
    this.backGroundColor = Colors.white,
    this.borderRadius = 4.0,
    this.slideColor = Colors.blue,
    this.cellWidth = 60,
    this.cellHeight = 40,
    this.valueFontSize = 13,
    this.slideMargin = 4,
    this.selectLabelColor,
    this.normalLabelColor,
  }) : super(key: key);

  @override
  _FloatTabViewState createState() => _FloatTabViewState();
}

class _FloatTabViewState extends State<FloatTabView> with TickerProviderStateMixin {
  int selectIndex = 0;
  int preSelectIndex = 0;
  Animation<RelativeRect> animation; //动画对象
  AnimationController controller; //动画控制器
  RelativeRect currentRect;
  Animation<Color> _preAnimation;
  Animation<Color> _selectAnimation;

  @override
  void initState() {
    super.initState();
    this.selectIndex = this.widget.initSelectIndex;
    controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    double totalWidth = this.widget.values.length * this.widget.cellWidth;
    double left = this.selectIndex * this.widget.cellWidth;
    double right = totalWidth - left - this.widget.cellWidth;
    currentRect = RelativeRect.fromLTRB(left, 0.0, right, 0);
    RelativeRectTween rectTween = RelativeRectTween(
      begin: currentRect,
      end: currentRect,
    );
    animation = rectTween.animate(controller);
    animation.addStatusListener((status) {});
    _selectAnimation = ColorTween(begin: Colors.red, end: Colors.white).animate(controller);
    _preAnimation = ColorTween(begin: Colors.white, end: Colors.red).animate(controller);
    //添加动画执行刷新监听
    controller.addListener(() {
      setState(() {});
    });
    controller.forward();
  }

  void updateSelectIndex(index) {
    if (index == this.selectIndex) {
      return;
    }

    this.setState(() {
      this.preSelectIndex = this.selectIndex;
      this.selectIndex = index;
      double totalWidth = this.widget.values.length * this.widget.cellWidth;
      double left = this.selectIndex * this.widget.cellWidth;
      double right = totalWidth - left - this.widget.cellWidth;

      RelativeRect newRect = RelativeRect.fromLTRB(left, 0.0, right, 0.0);
      // print("current rect is :$currentRect , new Rect is :$newRect");
      // print("new left is:$left right is :$right");
      RelativeRectTween rectTween = RelativeRectTween(
        begin: currentRect,
        end: newRect,
      );
      animation = rectTween.animate(controller);
      _selectAnimation = ColorTween(begin: this.widget.normalLabelColor, end: this.widget.selectLabelColor).animate(controller);
      _preAnimation = ColorTween(begin: this.widget.selectLabelColor, end: this.widget.normalLabelColor).animate(controller);
      currentRect = newRect;
    });
    controller.reset();
    controller.forward();

    // _animationColorController.reset();
    // _animationColorController.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget _buildCell(int index) {
    String value = this.widget.values[index];
    if (index == this.selectIndex) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          updateSelectIndex(index);
        },
        child: Container(
          child: ClipRRect(
            // borderRadius: BorderRadius.all(Radius.circular(this.widget.borderRadius)),
            child: Container(
              width: this.widget.cellWidth,
              height: this.widget.cellHeight,
              child: Center(
                child: Text(
                  value,
                  style: TextStyle(fontSize: this.widget.valueFontSize, color: _selectAnimation.value),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: () {
        updateSelectIndex(index);
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        width: this.widget.cellWidth,
        height: this.widget.cellHeight,
        child: Center(
          child: Text(
            value,
            style: TextStyle(fontSize: this.widget.valueFontSize, color: index == preSelectIndex ? _preAnimation.value : this.widget.normalLabelColor),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (int i = 0; i < (this.widget.values ?? []).length; i++) {
      children.add(
        _buildCell(i),
      );
    }
    return Container(
      height: this.widget.cellHeight + this.widget.borderWidth * 2,
      width: (this.widget.values.length * this.widget.cellWidth) + this.widget.borderWidth * 2,
      // color: Colors.red,
      child: Stack(
        children: <Widget>[
          PositionedTransition(
            //这玩意必须作为Stack的子widget
            rect: animation,
            child: IgnorePointer(
              child: Container(
                margin: EdgeInsets.all(this.widget.slideMargin),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(this.widget.borderRadius)),
                  child: Container(
                    decoration: BoxDecoration(color: this.widget.slideColor),
                  ),
                ),
              ),
            ),
          ),
          Container(
            // color: Colors.black26,
            height: this.widget.cellHeight + 4,
            decoration: BoxDecoration(
                border: Border.all(color: this.widget.borderColor, width: this.widget.borderWidth),
                borderRadius: BorderRadius.all(Radius.circular(this.widget.borderRadius))),
            // height: 200,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}
