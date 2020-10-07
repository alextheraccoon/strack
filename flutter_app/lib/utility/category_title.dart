import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'category.dart';

const _rowHeight = 100.0;
final _borderRadius = BorderRadius.circular(_rowHeight / 2);

/// A [CategoryTile] to display a [Category].
class CategoryTile extends StatelessWidget {
  final Category category;
  final ValueChanged<Category> onTap;

  /// The [CategoryTile] shows the name and color of a [Category] for unit
  /// conversions.
  ///
  /// Tapping on it brings you to the unit converter.
  const CategoryTile({
    Key key,
    @required this.category,
    @required this.onTap,
  })  : assert(category != null),
        assert(onTap != null),
        super(key: key);

  /// Builds a custom widget that shows [Category] information.
  ///
  /// This information includes the icon, name, and color for the [Category].
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: _rowHeight,
        child: InkWell(
          borderRadius: _borderRadius,
          highlightColor: category.color['highlight'],
          splashColor: category.color['splash'],
          onTap: () => onTap(category),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                ),
                Center(
                  child: Row(
                    children: <Widget>[
                      Icon(category.icon, color: Colors.black, size: 30,),
                      Container(width: 20,),
                      Text(
                        category.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ],
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}