/// Represents the position of a barcode in an image.
class Position {
  /// Creates an instance of [Position].
  Position(
    this.imageWidth,
    this.imageHeight,
    this.topLeftX,
    this.topLeftY,
    this.topRightX,
    this.topRightY,
    this.bottomLeftX,
    this.bottomLeftY,
    this.bottomRightX,
    this.bottomRightY,
  );

  /// width of the image
  int imageWidth;

  /// height of the image
  int imageHeight;

  /// x coordinate of top left corner of barcode
  int topLeftX;

  /// y coordinate of top left corner of barcode
  int topLeftY;

  /// x coordinate of top right corner of barcode
  int topRightX;

  /// y coordinate of top right corner of barcode
  int topRightY;

  /// x coordinate of bottom left corner of barcode
  int bottomLeftX;

  /// y coordinate of bottom left corner of barcode
  int bottomLeftY;

  /// x coordinate of bottom right corner of barcode
  int bottomRightX;

  /// y coordinate of bottom right corner of barcode
  int bottomRightY;
}
